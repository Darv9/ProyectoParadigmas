require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'
require 'json'

# Configura tu API key (idealmente desde una variable de entorno)
api_key = ENV['OPENAI_API_KEY'] || 'sk-_lcM1OOKDvCRvdXULhIspkzMf_LiMmJwJkg9PbbcIBT3BlbkFJ4QU8KjqtDXbN_NvYg7I-baNGzxH-qFPjjTwyBhCnEA'

# Configuración de Sinatra
configure do
  enable :sessions
  register Sinatra::CrossOrigin
  enable :cross_origin
  set :views, 'views'  # Configura la carpeta para las vistas ERB
end

before do
  # Configuración global de CORS
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['GET', 'POST', 'OPTIONS'],
          'Access-Control-Allow-Headers' => ['Content-Type']
end

# Ruta principal para mostrar la página
get '/' do
  erb :index
end

# Ruta para manejar el envío de mensajes
post '/send_message' do
  user_message = JSON.parse(request.body.read)['message']

  # Inicializa la conversación si es la primera vez
  session[:messages] ||= [
    { role: 'system', content: 'You are a supportive assistant trained to provide helpful advice and information about mental health and emotional well-being. You should offer empathetic and understanding responses.' }
  ]

  # Envía el mensaje y obtiene la respuesta
  response_text = send_message(api_key, user_message, session[:messages])

  # Retorna la respuesta en formato JSON
  content_type :json
  { response: response_text }.to_json
end

# Función para enviar un mensaje a la API de OpenAI
def send_message(api_key, user_message, messages)
  uri = URI.parse('https://api.openai.com/v1/chat/completions')
  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  # Añade el mensaje del usuario a la conversación
  messages << { role: 'user', content: user_message }

  body = {
    model: 'gpt-3.5-turbo',
    messages: messages
  }.to_json

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body

  begin
    response = http.request(request)
    response_body = JSON.parse(response.body)

    # Manejo de errores
    if response_body['choices']
      # Añade la respuesta del asistente a la conversación
      messages << { role: 'assistant', content: response_body['choices'][0]['message']['content'] }
      response_body['choices'][0]['message']['content']
    else
      "Error en la respuesta de la API: #{response_body}"
    end
  rescue => e
    "Error al comunicarse con la API: #{e.message}"
  end
end

# Manejo de la solicitud OPTIONS para manejar preflight requests de CORS
options '/*' do
  200
end
