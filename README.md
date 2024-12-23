# CIE 237: Probability and Stochastic Processes Fall 2024
A Flutter project that bridges MATLAB with Flutter using a Flask server and MATLAB engine API and this server is tunneled by Ngrok.

## Key Features

1. **File Upload**: Users select and upload `.mat` files.
2. **Data Processing**: Supports different types of analyses:
   - Single Variable Analysis
   - Joint Variable Analysis
   - Functions on Random Variable Analysis
3. **Visualization**: Retrieves the plots generated by MATLAB using the server:
   - Probability Density Function (PDF)
   - Cumulative Distribution Function (CDF)
   - Moment Generating Function (MGF) and its derivatives plots
   - Distribution plots (2D/3D, marginal, joint, etc.)
4. **Dynamic Inputs**: Prompts users for additional parameters based on the selected analysis.
## Technologies Used
### Frontend
- **Flutter**: Framework for building the mobile application.
- **Cubit**: State management for controlling UI states and file processing logic.
- **File Picker**: For selecting `.mat` files.

### Backend
- **Flask**: Python-based backend server.
- **MATLAB Engine API for Python**: Executes MATLAB commands and interacts with `.mat` files.
- **Ngrok**: Exposes the local Flask server to the internet.
## Supported Operations

### 1. Single Variable Analysis
- **Inputs**: `Number of Bins`, `T Range`
- **Outputs**:
  - Mean, Variance, Third Moment
  - PDF, CDF, and MGF Plots

### 2. Joint Variable Analysis
- **Inputs**: `Number of Bins`
- **Outputs**:
  - Means, Variances, Covariance, Correlation
  - 2D/3D Distribution, Marginal Distribution Plots

### 3. Function Analysis
- **Inputs**: `Number of Bins`, Transformations `Z` and `W`
- **Outputs**:
  - Means, Covariance, Correlation
  - Distribution and Joint Plots

## Prerequisites
- MATLAB installed on the server machine.
- Flask server set up with the provided `app.py`.
- Ngrok for exposing the local server (Optional if you remove `start_ngrok` function from `aap.py`).
- Change `serverBaseUrl` in `FileProcessCubit` to your local host OR to your Ngrok endpoint but in this case also change `ngrok_url` in `app.py`.

