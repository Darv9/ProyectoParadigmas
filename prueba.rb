require 'net/http'
require 'uri'
require 'json'

# Función para enviar y recibir mensajes en el chat
def send_message(api_key, user_message, messages)
  uri = URI.parse('https://api.openai.com/v1/chat/completions')
  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  # Añade el mensaje del usuario a la conversación
  messages << { role: 'user', content: user_message }

  body = {
    model: 'gpt-3.5-turbo',  # Usa gpt-3.5-turbo
    messages: messages
  }.to_json

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body

  response = http.request(request)
  response_body = JSON.parse(response.body)

  # Manejo de errores y depuración
  if response_body['choices']
    # Añade la respuesta del asistente a la conversación
    messages << { role: 'assistant', content: response_body['choices'][0]['message']['content'] }
    response_body['choices'][0]['message']['content']
  else
    "Error en la respuesta de la API: #{response_body}"
  end
end

puts "prueba.rb se ha cargado correctamente"
