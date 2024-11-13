<!DOCTYPE html>
<html>
<head>
    <title>Database Query Tool</title>
    <style>
        body {
            font-family: sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .container {
            border: 1px solid #ccc;
            padding: 20px;
            border-radius: 5px;
        }

        textarea {
            width: 100%;
            height: 100px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Database Query Tool</h1>
        <p>Developed by ishaan</p> 

        <form method="post">
            <textarea name="query" placeholder="Enter your SQL query here..."></textarea><br>
            <input type="submit" value="Execute Query">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $query = $_POST['query'];
            if (!empty($query)) {
                // Database connection details (replace with your own)
                $dbHost = "localhost";
                $dbName = "your_database_name";
                $dbUser = "your_database_user";
                $dbPass = "your_database_password";

                try {
                    $conn = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
                    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                    if ($conn->exec($query) === false) {
                        // Query returned a result set (SELECT, SHOW, etc.)
                        $stmt = $conn->query($query);
                        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

                        if (!empty($result)) {
                            echo '<table>';
                            echo '<thead><tr>';
                            foreach (array_keys($result[0]) as $column) {
                                echo "<th>$column</th>";
                            }
                            echo '</tr></thead>';
                            echo '<tbody>';
                            foreach ($result as $row) {
                                echo '<tr>';
                                foreach ($row as $value) {
                                    echo "<td>$value</td>";
                                }
                                echo '</tr>';
                            }
                            echo '</tbody>';
                            echo '</table>';
                        } else {
                            echo "<p>No results found.</p>";
                        }
                    } else {
                        // Query was a DML statement (UPDATE, DELETE, INSERT)
                        $rowsAffected = $conn->exec($query);
                        echo "<p>$rowsAffected rows affected.</p>";
                    }

                } catch (PDOException $e) {
                    echo "<p style='color: red;'>Error executing query: " . $e->getMessage() . "</p>";
                }
            } else {
                echo "<p>Please enter a query.</p>";
            }
        }
        ?>
    </div>
    <footer>
        <p>Developed by ishaan</p>
    </footer>
</body>
</html>
