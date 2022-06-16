from flask import Flask, request, send_from_directory
from flask_restful import Api, Resource, reqparse 
import werkzeug
import subprocess
import os
import json
import time 

from werkzeug.wrappers import Request 

app = Flask(_name_)
api = Api(app)

class Hello(Resource):
  def get(self):
    return { "Message": "Flask API is running!!!" }

class GetFile(Resource): #receiving the sound file
  def get(self):
    return send_from_directory(directory="C:\\Users\\ab\\Documents\\jythonMusic", filename="sound.mid")

#returning the sound file to the user 
class Home(Resource):
  def post(self):
    proc = subprocess.Popen(["sonify.cmd"], stdout=subprocess.PIPE)
    os.system('timeout 5')
    os.system('taskkill /F /PID' + str(proc.pid))
    return { "Message": "Hello World"}

class File(Resource):
  def post(self):
    parse = reqparse.RequestParser()
    parse.add_argument('file', type=werkzeug.datastructures.FileStorage, location='files')
    args = parse.parse_args()
    image_file = args['file']
    image_file.save("your_file_name.jpg")
    proc = subprocess.Popen(["sonify.cmd"], stdout=subprocess.PIPE)
    os.system('timeout 5')
    os.system('taskkill /F /PID' + str(proc.pid))
    return { "details": "OK "}

api.add_resource(Hello, "/")
api.add_resource(Home, "/home")
api.add_resource(File, "/sonify")
api.add_resource(GetFile, "/getfile")

if _name_ == "_main_":
  app.run(host='0.0.0.0', port=80)

  