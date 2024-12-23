# CIE 237: Probability and Stochastic Processes Fall 2024
----
A Flutter project that bridges MATLAB with Flutter using a Flask server and MATLAB engine API and this server is tunneled by Ngrok.

## Requirements
1. licensed MATLAB software.
2. installing requirements.txt in Python Server => `pip install -r requirements.txt`.
3. changinge ==serverBaseUrl== in **lib\bloc\File Uploader\fileprocesscubit.dart** to your local host or to your Ngrok endpoint.
4. if using Ngrok change the ==ngrok_url== in **Python server\app.py** to your endpoint if not just delete the ==start_ngrok== function.
----
## Python Server 
