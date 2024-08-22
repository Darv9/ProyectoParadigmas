require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'
require 'json'

# Configura el API KEY
api_key = ENV['OPENAI_API_KEY'] || 'sk-_lcM1OOKDvCRvdXULhIspkzMf_LiMmJwJkg9PbbcIBT3BlbkFJ4QU8KjqtDXbN_NvYg7I-baNGzxH-qFPjjTwyBhCnEA'

# Configuración de Sinatra
configure do
  enable :sessions
  register Sinatra::CrossOrigin
  enable :cross_origin
  set :views, 'views' 
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

  # Verifica si el mensaje del usuario está relacionado con salud mental
  if relevant_message?(user_message)
    # Inicializa la conversación si es la primera vez
    session[:messages] ||= [
      { role: 'system', content: 'You are a supportive assistant trained to provide advice and information exclusively about mental health and emotional well-being. Please ensure that all responses strictly adhere to this topic and do not address other subjects.' }
    ]

    # Envía el mensaje y obtiene la respuesta
    response_text = send_message(api_key, user_message, session[:messages])
  else
    response_text = "Lo siento, solo puedo hablar sobre salud mental y bienestar emocional. Por favor, haz una pregunta relacionada con estos temas."
  end

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
      assistant_message = response_body['choices'][0]['message']['content']
      
      # Verifica si la respuesta está en el tema
      if relevant_response?(assistant_message)
        messages << { role: 'assistant', content: assistant_message }
        assistant_message
      else
        # Mensaje de error o advertencia si la respuesta no es relevante
        "Error: La respuesta no está relacionada con salud mental o bienestar emocional."
      end
    else
      "Error en la respuesta de la API: #{response_body}"
    end
  rescue => e
    "Error al comunicarse con la API: #{e.message}"
  end
end

# Función para verificar si el mensaje está relacionado con salud mental
def relevant_message?(message)
  keywords = ["salud mental", "bienestar emocional", "ansiedad", "depresión", "estrés", "autoayuda"]
  keywords.any? { |keyword| message.downcase.include?(keyword) }
end

# Función para verificar si la respuesta es relevante para salud mental
def relevant_response?(message)
  relevant_message?(message)
end

# Manejo de la solicitud OPTIONS para manejar preflight requests de CORS
options '/*' do
  200
end
