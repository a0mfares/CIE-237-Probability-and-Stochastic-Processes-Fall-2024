import re
from flask import Flask, request, jsonify, send_file, url_for
import os
import matlab.engine
import numpy as np
from scipy.io import loadmat  
import shutil
import subprocess
app = Flask(__name__)

# Path to save uploaded file
UPLOAD_FOLDER = 'uploads/'  
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
# Start MATLAB engine
eng = matlab.engine.start_matlab()
# starts the ngrok service to host the local server on the internet
def start_ngrok():
    ngrok_url = "kit-trusted-silkworm.ngrok-free.app"
    port = 5000
    command = f"ngrok http --url={ngrok_url} {port}"
    subprocess.Popen(command, shell=True)

@app.route('/upload', methods=['POST','GET'])
def upload_file():
    # Clean the upload folder before processing a new file
    for filename in os.listdir(app.config['UPLOAD_FOLDER']):
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)  
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)  
        except Exception as e:
            return jsonify({"error": f"Failed to clean upload folder: {e}"}), 500
    # checks if user inputs a file
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    # get the file from request
    file = request.files['file']

    # checks if user inputs a file
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    # Ensure the file is a .mat file
    if not file.filename.endswith('.mat'):
        return jsonify({"error": "Only .mat files are supported"}), 400

    # Save file to server
    filename = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(filename)
    

    Nob = float(request.form.get('Number of Bins'))
    index = int(request.form.get('index'))
    if index == 0:
        Trange = float(request.form.get('T Range'))
    if index == 2:
        TransZ = request.form.get('TransZ')
        TransW =request.form.get('TransW')
    # Load the .mat file 
    mat_data = loadmat(filename)  
    # Get variables inside the .mat file
    variable_names = list(mat_data.keys())
    # Get the last variable name dynamically from the .mat file
    variable_name = variable_names[-1]
    # loads sample data
    sample = mat_data[variable_name]
    # converts sample data to matlab array of doubles
    sample_matlab = matlab.double(sample.tolist())

    # Load All MATLAB classes in the directory
    eng.eval("addpath('.')", nargout=0)

    if index == 0:
        # Initialize SingleRVAnalysis class with the sample data, Number of Bins and T range
        obj = eng.SingleRVAnalysis_Smooth(sample_matlab, matlab.double(Nob), matlab.double(Trange))  

        # Compute statistics
        mean = eng.getfield(obj,"Mean")
        variance = eng.getfield(obj,"Variance")
        third_moment = eng.getfield(obj,"ThirdMoment")
        # Compute MGF, MGF' and MGF''
        mgf_prime = eng.getfield(obj,"MGF_Prime_0")
        mgf_double_prime = eng.getfield(obj,"MGF_doublePrime_0")
        # creating local storage for plots
        pdf_filename = os.path.join(app.config['UPLOAD_FOLDER'], "pdf_plot.png")
        cdf_filename = os.path.join(app.config['UPLOAD_FOLDER'], "cdf_plot.png")
        mgf_filename = os.path.join(app.config['UPLOAD_FOLDER'], "mgf_plot.png")
        mgfPrime_filename = os.path.join(app.config['UPLOAD_FOLDER'], "mgf_prime_plot.png")
        mgfDoublePrime_filename = os.path.join(app.config['UPLOAD_FOLDER'], "mgf_doubleprime_plot.png")
        # Plot the PDF 
        eng.plotPDF(obj, pdf_filename, nargout=0)
        pdf_url = url_for('uploaded_file', filename='pdf_plot.png', _external=True)
        # Plot the CDF 
        eng.plotCDF(obj, cdf_filename, nargout=0)
        cdf_url = url_for('uploaded_file', filename='cdf_plot.png', _external=True)
        # Plot the MGF 
        eng.plotMGF(obj, mgf_filename, nargout=0)
        mgf_url = url_for('uploaded_file', filename='mgf_plot.png', _external=True)
        # Plot the MGF prime
        eng.plotMGF_prime(obj, mgfPrime_filename, nargout=0)
        mgf_prime_url = url_for('uploaded_file', filename='mgf_prime_plot.png', _external=True)
        # Plot the MGF double prime
        eng.plotMGF_doublePrime(obj, mgfDoublePrime_filename, nargout=0)
        mgf_doublePrime_url = url_for('uploaded_file', filename='mgf_doubleprime_plot.png', _external=True)
        



        # Return the results and plot URLs
        response = {
            "Mean": mean,
            "Variance": variance,
            "ThirdMoment": third_moment,
            "PDF": pdf_url,
            "CDF":cdf_url,
            "MGF Prime": mgf_prime,
            "MGF Double Prime":mgf_double_prime,
            "MGF URL": mgf_url,
            "MGF Prime URL": mgf_prime_url,
            "MGF Double Prime URL":mgf_doublePrime_url
        }
    if index == 1:
        # Initialize JointRVAnalysis class with the sample data, Number of Bins
        obj = eng.JointRVAnalysis(sample_matlab, matlab.double(Nob))  
        Mean_X , Var_X = eng.calculateStatistics_X(obj,nargout=2)
        Mean_Y , Var_Y = eng.calculateStatistics_Y(obj,nargout=2)
        Covariance = eng.calculate_covariance(obj)
        Correlation = eng.calculate_correlation(obj)
        # creating local storage for plots
        plot2d_filename = os.path.join(app.config['UPLOAD_FOLDER'], "2d_dist_plot.png")
        plot3d_filename = os.path.join(app.config['UPLOAD_FOLDER'], "3d_dist_plot.png")
        mariginal_X_filename = os.path.join(app.config['UPLOAD_FOLDER'], "mariginal_X_plot.png")
        mariginal_Y_filename = os.path.join(app.config['UPLOAD_FOLDER'], "mariginal_y_plot.png")
        # Plot the 2D distribution  
        eng.plot_2d_distribution(obj, plot2d_filename, nargout=0)
        plot2d_url = url_for('uploaded_file', filename='2d_dist_plot.png', _external=True)
        # Plot the 3D distribution 
        eng.plot_3d_distribution(obj, plot3d_filename, nargout=0)
        plot3d_url = url_for('uploaded_file', filename='3d_dist_plot.png', _external=True)
        # Plot mariginal X
        eng.plot_mariginal_X(obj, mariginal_X_filename, nargout=0)
        mariginal_X_url = url_for('uploaded_file', filename='mariginal_X_plot.png', _external=True)
        # Plot mariginal Y
        eng.plot_mariginal_Y(obj, mariginal_Y_filename, nargout=0)
        mariginal_y_url = url_for('uploaded_file', filename='mariginal_y_plot.png', _external=True)
        
        
        # Return the results and plot URLs
        response = {
            "Mean X": Mean_X,
            "Variance X": Var_X,
            "Mean Y": Mean_Y,
            "Variance Y": Var_Y,
            "Covariance": Covariance,
            "Correlation": Correlation,
            "2D distribution":plot2d_url,
            "3D distribution": plot3d_url,
            "mariginal X": mariginal_X_url,
            "mariginal Y":mariginal_y_url
        }
    elif index == 2:
        # Initialize FunctionAnalysis class with the sample data, Number of Bins, transform functions Z and W
        obj = eng.FunctionAnalysis(sample_matlab, matlab.double(Nob), eng.str2func(to_matlab_function_handler(TransZ)),eng.str2func(to_matlab_function_handler(TransW)))  
        Mean_X , Mean_Z = eng.calculateMeansZ(obj,nargout=2)
        Mean_Y , Mean_W = eng.calculateMeansW(obj,nargout=2)
        Covariance = eng.calculateCov(obj, nargout= 1)
        Correlation = eng.calculateCorr(obj, nargout= 1)
        # creating local storage for plots
        plotZdist_filename = os.path.join(app.config['UPLOAD_FOLDER'], "Z_dist_plot.png")
        plotWdist_filename = os.path.join(app.config['UPLOAD_FOLDER'], "W_dist_plot.png")
        jointPlot_filename = os.path.join(app.config['UPLOAD_FOLDER'], "joint_plot.png")
        # Plot the Z distribution  
        eng.plot_dis_Z(obj, plotZdist_filename, nargout=0)
        plotZdist_url = url_for('uploaded_file', filename='Z_dist_plot.png', _external=True)
        # Plot the W distribution 
        eng.plot_dis_W(obj, plotWdist_filename, nargout=0)
        plotWdist_url = url_for('uploaded_file', filename='W_dist_plot.png', _external=True)
        # Plot Joint plot
        eng.plot_joint(obj, jointPlot_filename, nargout=0)
        jointPlot_url = url_for('uploaded_file', filename='joint_plot.png', _external=True)
        
        
        # Return the results and plot URLs
        response = {
            "Mean X": Mean_X,
            "Mean Z": Mean_Z,
            "Mean Y": Mean_Y,
            "Mean W": Mean_W,
            "Covariance": Covariance,
            "Correlation": Correlation,
            "Z distribution":plotZdist_url,
            "W distribution": plotWdist_url,
            "Joint": jointPlot_url,
        }
    return jsonify(response)
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_file(os.path.join(app.config['UPLOAD_FOLDER'], filename))
def to_matlab_function_handler(expression: str) -> str:
    """
    Converts a string mathematical expression into MATLAB function handler syntax,
    automatically detecting the variable.
    
    Args:
        expression (str): The mathematical expression as a string (e.g., "2x - 1").
    
    Returns:
        str: The MATLAB function handler as a string.
    """
    # Detect the variable using a regex (assumes single-letter variables)
    variable_match = re.findall(r'[a-zA-Z]', expression)
    if not variable_match:
        raise ValueError("No variable found in the expression.")
    
    # Use the first detected variable (or modify as needed for multiple variables)
    variable = variable_match[0]
    
    # Insert explicit multiplication where implied (e.g., "2x" -> "2*x")
    expression = re.sub(rf'(\d)({variable})', r'\1*\2', expression)
    
    # Replace '^' (if any) with '**' for MATLAB compatibility
    expression = expression.replace("^", ".^")
    
    return f"@({variable}) {expression}"
if __name__ == '__main__':
    start_ngrok()
    app.run(host='0.0.0.0', port=5000)