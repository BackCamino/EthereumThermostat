import bluetooth

def receiveMessages():
  server_sock=bluetooth.BluetoothSocket( bluetooth.RFCOMM )
  
  port = 1
  server_sock.bind(("",port))
  server_sock.listen(1)
  
  while True:
      client_sock,address = server_sock.accept()
      print ("Accepted connection from " + str(address))
      try:
          while True:
              data = client_sock.recv(1024)
              if not data:
                  break
              print ("received [%s]" % data)
              analyzeMessage(data, client_sock)
      except OSError:
         print("Smartphone disconnected")
         client_sock.close()
         
  server_sock.close()
  
def sendMessageTo(sock, message):
  sock.send(message)

def analyzeMessage(data,sock ):
  data = data.decode("utf-8")
  if(data == "getdevices"):
    sendMessageTo(sock, lookUpNearbyBluetoothDevices())
  else:
    subdata = data.split("#")
    if(subdata[0] == "add"):
        #deploy sensor
        sendMessageTo(sock, "ok#" + subdata[1])
      

def lookUpNearbyBluetoothDevices():
  nearby_devices = bluetooth.discover_devices()
  response = ""
  if(len(nearby_devices) == 0):
      response = "nodevice"
  for device_addr in nearby_devices:
    print (str(bluetooth.lookup_name(device_addr)) + " [" + str(device_addr) + "]")
    response = response + str(bluetooth.lookup_name(device_addr)) + "&" + str(device_addr) + "#"
  return response
    
receiveMessages()
