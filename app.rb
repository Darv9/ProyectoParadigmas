# require 'sinatra'
# require 'json'
# require 'rack/cors'
# #Cambiar a la ruta de cada uno donde tenga el archivo prueba.rb
# require 'D:/Repos/ProyectoParadigmas/prueba'



# # Configuración de CORS
# use Rack::Cors do
#   allow do
#     origins '*'
#     resource '*',
#       headers: :any,
#       methods: [:get, :post, :options]
#   end
# end

# api_key = 'sk-_lcM1OOKDvCRvdXULhIspkzMf_LiMmJwJkg9PbbcIBT3BlbkFJ4QU8KjqtDXbN_NvYg7I-baNGzxH-qFPjjTwyBhCnEA'

# post '/chat' do
#   content_type :json
#   request_payload = JSON.parse(request.body.read)
#   user_message = request_payload['message']

#   messages = [
#     { role: 'system', content: 'You are a helpful assistant that only discusses topics related to Mental Health $ Emotional Wellness (Mental Health).' }
#   ]
  
#   response = send_message(api_key, user_message, messages)
  
#   { response: response }.to_json
# end

# options '/chat' do
#   content_type :json
#   status 200
# end

require 'sinatra'
require 'net/http'
require 'json'

# Configura tu API key
api_key = 'sk-_lcM1OOKDvCRvdXULhIspkzMf_LiMmJwJkg9PbbcIBT3BlbkFJ4QU8KjqtDXbN_NvYg7I-baNGzxH-qFPjjTwyBhCnEA'

# Habilita la sesión
enable :sessions

# Ruta principal para mostrar la página
get '/' do
  erb :index
end

# Ruta para manejar el envío de mensajes
post '/send_message' do
  user_message = params[:message]

  # Inicializa la conversación si es la primera vez
  session[:messages] ||= [
    { role: 'system', content: 'You are a helpful assistant that only discusses topics related to football (soccer).' }
  ]

  # Envía el mensaje y obtiene la respuesta
  response = send_message(api_key, user_message, session[:messages])

  # Muestra la respuesta en la vista
  erb :index, locals: { response: response }
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
end
