<?php

$action = $_GET['action'];

$connString = 'mysql:dbname=utopiales2013;host=samuel-bouchet.fr';


if($action == 'get'){

    try{
        $conn = new PDO($connString, 'utopiales2013', 'utopiales2013pwd');
		$level = $_GET['level'];
        $prep = $conn->prepare('SELECT * FROM score WHERE level = :level ORDER BY score DESC, date ASC LIMIT 10');
		$prep->execute(array(':level' => $level));
        $json=json_encode($prep->fetchAll(PDO::FETCH_ASSOC));
        print($json);
    } catch (PDOException $e) {
        echo 'Connexion échouée : ' . $e->getMessage();
    }
}

if($action == 'save'){
    try {
		$key = $_GET['key'];
		if ($key == "qsdfghjkl") {
			$pseudo = $_GET['pseudo'];
			$score = $_GET['score'];
			$level = $_GET['level'];
			
			$conn = new PDO($connString, 'utopiales2013', 'utopiales2013pwd');
			$prep = $conn->prepare('INSERT INTO score VALUES (null, :pseudo, :score, null, :level)');
			$result = $prep->execute(array(':pseudo' => $pseudo, ':score' => $score, ':level' => $level));
			if ($result) {
				$insertedId = $conn->lastInsertId();
				print('{result:' + $insertedId + '}');
			} else {
				print_r($prep->errorInfo());
			}
			
		}

    } catch (PDOException $e) {
        echo 'Connexion échouée : ' . $e->getMessage();
    }
}

?>