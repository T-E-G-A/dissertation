# Project Setup Instructions

This document outlines the steps required to set up and run the PHP, Node.js, and Flutter comparison project. It includes software installation, database setup, backend server startup, and frontend execution. Read through before performing any action.

## Software Installation

Before proceeding, ensure you have the following software installed.

| Software | Link | Notes |
|---|---|---|
| Node.js | [https://nodejs.org/en](https://nodejs.org/en) | Required for the Node.js backend. |
| Composer (Laravel) | [https://getcomposer.org/](https://getcomposer.org/) | Required for the Laravel backend. |
| HeidiSQL | [https://www.heidisql.com/](https://www.heidisql.com/) | Database management tool. |
| VS Code | [https://code.visualstudio.com/](https://code.visualstudio.com/) | Code editor (recommended). |
| MySQL (XAMPP/WAMP) | [https://www.apachefriends.org/download.html](https://www.apachefriends.org/download.html) / [https://sourceforge.net/projects/wampserver/](https://sourceforge.net/projects/wampserver/) | Database server. |
| Flutter (Optional) | [https://medium.com/@devstree.ca/getting-started-with-flutter-a-beginners-guide-742d1d355c01](https://medium.com/@devstree.ca/getting-started-with-flutter-a-beginners-guide-742d1d355c01) | Required only if you want to modify or run the Flutter app directly. |

## Project Extraction

1.  Extract the `PHP_NODE_FLUTTER_COMPARISON.zip` file to your desired location. If you are using XAMPP or WAMP, extract it to the `htdocs` or `www` directory, respectively.
    ```
    (Extract to htdocs or www)
    ```
    ![Extract Project](help/extract_project.png)

## Database Setup

1.  Launch HeidiSQL and connect to your MySQL server.
2.  Import the database located at `PHP_NODE_FLUTTER_COMPARISON/_db_sql.sql`. This will create the `laravel` and `nodejs` databases with all necessary tables and data.
    ```
    (Import _db_sql.sql in HeidiSQL)
    ```
    ![Import Database](help/import_database.png)

## Backend Server Startup

1.  **Laravel (PHP):**
    -   Navigate to the `/backend/php-laravel` directory in your terminal.
    -   Run the following command, replacing `192.168.1.1` with your local IP address (obtainable using `ipconfig` on Windows or `ifconfig` on Linux/macOS). 
        ```bash
        php artisan serve --host 192.168.1.1
        ```
    -   Leave this terminal window running.
        ```
        (Run php artisan serve)
        ```
        ![Laravel Serve](help/laravel_serve.png)

        > *You may need to install composer packages incase they didn't come bundled in this zip file.*

2.  **Node.js:**
    -   Open a new terminal window and navigate to the `/backend/nodejs` directory.
    -   Run the following command to install dependencies and start the server.
        ```bash
        npm start
        ```
    -   Leave this terminal window running.
        ```
        (Run npm start)
        ```
        ![NodeJS Start](help/nodejs_start.png)

        Normally you would run *node index.js* but I've handled that in package.json

## Frontend Execution

1.  **Flutter (If Flutter is installed):**
    -   Navigate to the `/frontend` directory in a new terminal window.
    -   Connect your mobile device or start an emulator.
    -   Run the following command to launch the Flutter app.
        ```bash
        flutter run
        ```
        ```
        (Run flutter run)
        ```
        ![Flutter Run](help/flutter_run.png)

2.  **Web (Without Flutter):**
    -   Open the `PHP_NODE_FLUTTER_COMPARISON/frontend/build/web/index.html` file in your web browser.
    -   If you extracted the project to your XAMPP or WAMP `htdocs` or `www` directory, you can access it via `http://127.0.0.1/PHP_NODE_FLUTTER_COMPARISON/frontend/build/web/index.html`.
        ```
        (Open index.html in browser)
        ```
        ![Xampp Running](help/xampp_running.png)
        ![Web Frontend](help/web_frontend.png)

3.  **Mobile APK (If Flutter is not installed):**
    -   Install the APK located at `PHP_NODE_FLUTTER_COMPARISON/frontend/oviasogie_school_mis.apk` on your Android device.
    -   Ensure your device and laptop are connected to the same network.
        ```
        (Install oviasogie_school_mis.apk)
        ```
        ![APK Install](help/apk_install.png)

## Accessing the Application

1.  Open your web browser or mobile app.
2.  Navigate to the appropriate URL or launch the installed app.
3.  You can log in as an admin or a learner to test the application. And access various aspects of the application.

## End
You have successfully set up and run the project.
