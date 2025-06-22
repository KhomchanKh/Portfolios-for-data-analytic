from flask import Flask,request,jsonify

app = Flask(__name__)

@app.route('/greet',methods=['get'])

def greet():
    name = request.args.get('name')
    if not name:
        return jsonify({'message':'Please provide your name'}),400
    return jsonify({'message':f'Hello {name}!!'}),200

if __name__ == '__main__':
    app.run(debug=True)
