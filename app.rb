require 'sinatra'
require 'json'
require 'rack/cors'
#Cambiar a la ruta de cada uno donde tenga el archivo prueba.rb
require 'C:/Users/Drave/OneDrive/Documentos/Cuatrimestre Final Fidelitas - Sistemas/Paradigmas Progamación/ProyectoParadigmas/ProyectoParadigmas/prueba'



# Configuración de CORS
use Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      methods: [:get, :post, :options]
  end
end

api_key = 'sk-_lcM1OOKDvCRvdXULhIspkzMf_LiMmJwJkg9PbbcIBT3BlbkFJ4QU8KjqtDXbN_NvYg7I-baNGzxH-qFPjjTwyBhCnEA'

post '/chat' do
  content_type :json
  request_payload = JSON.parse(request.body.read)
  user_message = request_payload['message']

  messages = [
    { role: 'system', content: 'You are a helpful assistant that only discusses topics related to Mental Health $ Emotional Wellness (Mental Health).' }
  ]
  
  response = send_message(api_key, user_message, messages)
  
  { response: response }.to_json
end

options '/chat' do
  content_type :json
  status 200
end