# Database Term Project Team 3


[![Video Label](http://img.youtube.com/vi/UnvHS4xcP7c/0.jpg)](https://youtu.be/UnvHS4xcP7c)



#### You have to fill in this part before you run it
``` Dart
final conn = await MySQLConnection.createConnection(
    host: '------',
    port: 1111,
    userName: "------",
    password: '------',
    databaseName: '------',
    secure: false,
  );
```

## Our Database Tables :
``` SQL
CREATE TABLE account(  
    id int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255)
);

CREATE TABLE media (
    media_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    type ENUM('jpeg','mp4') NOT NULL,
    file_path VARCHAR(255) NOT NULL
);

CREATE TABLE user (
    user_id INT PRIMARY KEY,
    name VARCHAR(255),
    birth DATE,
    media_id int,
    Foreign Key (user_id) REFERENCES account(id),
    Foreign Key (media_id) REFERENCES media(media_id)
);

CREATE TABLE following (
    follower_id INT,
    followee_id INT,
    PRIMARY KEY (follower_id, followee_id),
    FOREIGN KEY (follower_id) REFERENCES user(user_id),
    FOREIGN KEY (followee_id) REFERENCES user(user_id),
    UNIQUE (follower_id, followee_id)
);

CREATE TABLE post (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    writer_id INT,
    content TEXT,
    Foreign Key (user_id) REFERENCES user(user_id)
);

CREATE TABLE likes (
    post_id INT,
    user_id INT,
    PRIMARY KEY (post_id, user_id),
    Foreign Key (post_id) REFERENCES post(post_id),
    Foreign Key (user_id) REFERENCES user(user_id),
    UNIQUE (post_id, user_id)
);

CREATE TABLE comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_id INT,
    content TEXT,
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Foreign Key (user_id) REFERENCES user(user_id),
    Foreign Key (post_id) REFERENCES post(post_id)
);

CREATE TABLE retweet (
    retweet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_id INT,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (post_id) REFERENCES post(post_id),
    UNIQUE (user_id, post_id)
);

CREATE TABLE post_media (
    post_id INT,
    media_id INT,
    media_order INT,
    PRIMARY KEY (media_id),
    FOREIGN KEY (post_id) REFERENCES post(post_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id),
    UNIQUE (post_id, media_order)
);
```
