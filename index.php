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

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            border: 1px solid #ccc;
            padding: 8px;
            text-align: left;
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
        error_reporting(E_ALL);
        ini_set('display_errors', 1);

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $query = $_POST['query'];
            if (!empty($query)) {
                $dbHost = "localhost";
                $dbName = "imart"; 
                $dbUser = "imart_user";
                $dbPass = "kali";

                try {
                    $conn = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
                    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                    // Use prepare and execute for potentially unsafe queries
                    $stmt = $conn->prepare($query);
                    $stmt->execute();

                    // Check if the query potentially returns a result set
                    if ($stmt->columnCount() > 0) {
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
                        // Likely a DML statement, get the number of affected rows
                        $rowsAffected = $stmt->rowCount();
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
