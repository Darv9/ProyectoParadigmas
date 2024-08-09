require 'net/http'
require 'uri'
require 'json'

# Coloca tu clave API de OpenAI aquí
api_key = 'sk-_lcM1OOKDvCRvdXULhIspkzMf_LiMmJwJkg9PbbcIBT3BlbkFJ4QU8KjqtDXbN_NvYg7I-baNGzxH-qFPjjTwyBhCnEA'

# Configura el endpoint y el encabezado de la solicitud
uri = URI.parse('https://api.openai.com/v1/chat/completions')
headers = {
  'Content-Type' => 'application/json',
  'Authorization' => "Bearer #{api_key}"
}

# Define el mensaje del sistema para enfocar el tema de la conversación
messages = [
  { role: 'system', content: 'You are a helpful assistant that only discusses topics related to football (soccer).' },
  { role: 'user', content: 'Hello, how are you?' }
]

# Configura el cuerpo de la solicitud
body = {
  model: 'gpt-3.5-turbo',  # Usa gpt-3.5-turbo
  messages: messages
}.to_json

# Realiza la solicitud HTTP POST
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri, headers)
request.body = body

response = http.request(request)

# Parsear la respuesta y mostrar el contenido
response_body = JSON.parse(response.body)

# Manejo de errores y depuración
if response_body['choices']
  puts response_body['choices'][0]['message']['content']
else
  puts "Error en la respuesta de la API: #{response_body}"
end

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

# Interacción de ejemplo
puts "Inicia una conversación sobre fútbol:"
while true
  print "Tú: "
  user_input = gets.chomp
  break if user_input.downcase == 'salir'
  response = send_message(api_key, user_input, messages)
  puts "Asistente: #{response}"
end
