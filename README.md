***CIE 237: Probability and Stochastic Processes Fall 2024***

A project that bridges MATLAB with Flutter using a Flask server and MATLAB Engine API. Additionally, the project includes a standalone MATLAB desktop application for direct analysis and visualization.

Key Features
- **File Upload:** Users can select and upload .mat files via the Flutter app or the MATLAB desktop application.
- **Data Processing:** Supports various types of analyses:
  - Single Variable Analysis
  - Joint Variable Analysis
  - Functions on Random Variable Analysis
- **Visualization:** Generates and retrieves plots using MATLAB:
  - Probability Density Function (PDF)
  - Cumulative Distribution Function (CDF)
  - Moment Generating Function (MGF) and its derivatives
  - Distribution plots (2D/3D, marginal, joint, etc.)
- **Dynamic Inputs:** Prompts users for additional parameters based on the selected analysis type.

Technologies Used
### Flutter Application
- **Flutter:** Framework for building the mobile application.
- **Cubit:** State management for controlling UI states and file processing logic.
- **File Picker:** For selecting .mat files.

### MATLAB Desktop Application
- Standalone MATLAB app with a user-friendly GUI for selecting files, configuring analysis, and visualizing results.

### Backend
- **Flask:** Python-based backend server.
- **MATLAB Engine API for Python:** Executes MATLAB commands and interacts with .mat files.
- **Ngrok:** Exposes the local Flask server to the internet (optional).

Supported Operations
1. **Single Variable Analysis**
   - **Inputs:** Number of Bins, T Range
   - **Outputs:**
     - Mean, Variance, Third Moment
     - PDF, CDF, and MGF Plots

2. **Joint Variable Analysis**
   - **Inputs:** Number of Bins
   - **Outputs:**
     - Means, Variances, Covariance, Correlation
     - 2D/3D Distribution, Marginal Distribution Plots

3. **Function Analysis**
   - **Inputs:** Number of Bins, Transformations Z and W
   - **Outputs:**
     - Means, Covariance, Correlation
     - Distribution and Joint Plots

Prerequisites
- **MATLAB:** Installed on the server machine for backend processing and on the client machine for the desktop app.
- **Flask Server:** Set up with the provided `app.py`.
- **Ngrok:** For exposing the local server (optional if you remove the `start_ngrok` function from `app.py`).
- **Configuration:**
  - Update `serverBaseUrl` in `FileProcessCubit` to your localhost or Ngrok endpoint for the Flutter app.
  - Update `ngrok_url` in `app.py` if using Ngrok.

