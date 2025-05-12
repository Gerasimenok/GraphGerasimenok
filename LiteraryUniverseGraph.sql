USE master;
DROP DATABASE IF EXISTS LiteraryUniverseGraph;
CREATE DATABASE LiteraryUniverseGraph;
USE LiteraryUniverseGraph;

-- Создание таблиц узлов
--Book - книги
CREATE TABLE Book (
    id INT NOT NULL PRIMARY KEY,
    title NVARCHAR(100) NOT NULL,
    author NVARCHAR(100) NOT NULL,
    publication_year INT,
    rating DECIMAL(3, 2)  
) AS NODE;

--Character - персонажи
CREATE TABLE Character (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    is_protagonist BIT  
) AS NODE;

--Location - локации
CREATE TABLE Location (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    type NVARCHAR(50) CHECK (type IN ('Город', 'Замок', 'Лес', 'Планета', 'Другое'))
) AS NODE;

-- Создание таблиц рёбер 
--AppearsIn - связь "Персонаж → Книга" (персонаж появляется в книге)
CREATE TABLE AppearsIn AS EDGE; 

--LocatedIn - связь "Книга → Локация" (книга связана с локацией)
CREATE TABLE LocatedIn AS EDGE; 

--VisitedBy - связь "Персонаж → Локация" (персонаж посещает локацию) с указанием количества посещений
CREATE TABLE VisitedBy (
    visit_count INT DEFAULT 1
) AS EDGE; 

--RelatedTo - связь "Персонаж → Персонаж" с типом отношения (Друг, Семья, Союзник)
CREATE TABLE RelatedTo (
    relationship_type NVARCHAR(30) CHECK (relationship_type IN ('Друг', 'Враг', 'Семья', 'Союзник'))
) AS EDGE; 

--Mentions - связь "Книга → Локация" (книга упоминает локацию)
CREATE TABLE Mentions AS EDGE; 

-- Ограничения для рёбер
ALTER TABLE AppearsIn ADD CONSTRAINT EC_AppearsIn CONNECTION (Character TO Book);
ALTER TABLE LocatedIn ADD CONSTRAINT EC_LocatedIn CONNECTION (Book TO Location); 
ALTER TABLE VisitedBy ADD CONSTRAINT EC_VisitedBy CONNECTION (Character TO Location);
ALTER TABLE RelatedTo ADD CONSTRAINT EC_RelatedTo CONNECTION (Character TO Character);
ALTER TABLE Mentions ADD CONSTRAINT EC_Mentions CONNECTION (Book TO Location);

-- Заполнение таблиц узлов
-- Книги
INSERT INTO Book (id, title, author, publication_year, rating) VALUES
(1, 'Гарри Поттер и Философский камень', 'Дж. К. Роулинг', 1997, 4.8),
(2, 'Гарри Поттер и Тайная комната', 'Дж. К. Роулинг', 1998, 4.7),
(3, 'Гарри Поттер и Узник Азкабана', 'Дж. К. Роулинг', 1999, 4.9),
(4, 'Игра престолов', 'Джордж Р. Р. Мартин', 1996, 4.7),
(5, 'Буря мечей', 'Джордж Р. Р. Мартин', 2000, 4.8),
(6, 'Властелин Колец: Братство Кольца', 'Дж. Р. Р. Толкин', 1954, 4.9),
(7, 'Властелин Колец: Две крепости', 'Дж. Р. Р. Толкин', 1954, 4.8),
(8, 'Хоббит', 'Дж. Р. Р. Толкин', 1937, 4.7),
(9, 'Убить пересмешника', 'Харпер Ли', 1960, 4.8),
(10, '1984', 'Джордж Оруэлл', 1949, 4.6);

-- Персонажи
INSERT INTO Character (id, name, description, is_protagonist) VALUES
(1, 'Гарри Поттер', 'Главный герой серии о Гарри Поттере', 1),
(2, 'Гермиона Грейнджер', 'Подруга Гарри, одна из самых умных учениц Хогвартса', 1),
(3, 'Рон Уизли', 'Лучший друг Гарри', 1),
(4, 'Тирион Ланнистер', 'Карлик из рода Ланнистеров, известный своим умом', 1),
(5, 'Джон Сноу', 'Бастард Эддарда Старка', 1),
(6, 'Фродо Бэггинс', 'Хоббит, несущий Кольцо', 1),
(7, 'Гэндальф', 'Могущественный волшебник', 1),
(8, 'Аттикус Финч', 'Честный адвокат из "Убить пересмешника"', 1),
(9, 'Скаут Финч', 'Дочь Аттикуса, главная героиня', 1),
(10, 'Уинстон Смит', 'Главный герой "1984"', 1);

-- Локации
INSERT INTO Location (id, name, type) VALUES
(1, 'Хогвартс', 'Замок'),
(2, 'Косой переулок', 'Город'),
(3, 'Королевская Гавань', 'Город'),
(4, 'Стена', 'Другое'),
(5, 'Шир', 'Лес'),
(6, 'Мордор', 'Планета'),
(7, 'Майкомб', 'Город'),
(8, 'Океания', 'Планета'),
(9, 'Винтерфелл', 'Замок'),
(10, 'Риверран', 'Замок'),
(11, 'Лондон', 'Город'),
(12, 'Среднеземье', 'Другое');

-- Заполнение таблиц рёбер 
-- AppearsIn (Персонажи → Книги)
INSERT INTO AppearsIn ($from_id, $to_id)
SELECT c.$node_id, b.$node_id
FROM Character c, Book b
WHERE (c.id = 1 AND b.id IN (1, 2, 3)) OR
      (c.id = 2 AND b.id IN (1, 2, 3)) OR
      (c.id = 3 AND b.id IN (1, 2, 3)) OR
      (c.id = 4 AND b.id IN (4, 5)) OR
      (c.id = 5 AND b.id IN (4, 5)) OR
      (c.id = 6 AND b.id IN (6, 7)) OR
      (c.id = 7 AND b.id IN (6, 7, 8)) OR
      (c.id = 8 AND b.id = 9) OR
      (c.id = 9 AND b.id = 9) OR
      (c.id = 10 AND b.id = 10);

-- LocatedIn (Книга → Локация) 
INSERT INTO LocatedIn ($from_id, $to_id)
SELECT b.$node_id, l.$node_id
FROM Book b, Location l
WHERE 
    (b.id IN (1, 10) AND l.id = 11) OR
    (b.id IN (6, 8) AND l.id = 12) OR
    (b.id IN (1, 2, 3) AND l.id = 1) OR
    (b.id IN (1, 2, 3) AND l.id = 2) OR
    (b.id IN (4, 5) AND l.id = 3) OR
    (b.id IN (4, 5) AND l.id = 4) OR
    (b.id IN (6, 7) AND l.id = 5) OR
    (b.id IN (6, 7) AND l.id = 6) OR
    (b.id = 9 AND l.id = 7) OR
    (b.id = 10 AND l.id = 8) OR
    (b.id IN (4, 5) AND l.id = 9) OR
    (b.id IN (4, 5) AND l.id = 10);

-- VisitedBy (Персонажи → Локации)
INSERT INTO VisitedBy ($from_id, $to_id, visit_count)
SELECT c.$node_id, l.$node_id, 
       CASE WHEN c.id = 1 AND l.id = 1 THEN 10
            WHEN c.id = 1 AND l.id = 2 THEN 5
            WHEN c.id = 4 AND l.id = 3 THEN 8
            WHEN c.id = 5 AND l.id = 4 THEN 6
            WHEN c.id = 6 AND l.id = 5 THEN 7
            WHEN c.id = 7 AND l.id = 6 THEN 3
            WHEN c.id = 8 AND l.id = 7 THEN 12
            WHEN c.id = 9 AND l.id = 7 THEN 15
            WHEN c.id = 10 AND l.id = 8 THEN 20
            ELSE 1
       END
FROM Character c, Location l
WHERE (c.id = 1 AND l.id IN (1, 2)) OR
      (c.id = 4 AND l.id = 3) OR
      (c.id = 5 AND l.id = 4) OR
      (c.id = 6 AND l.id = 5) OR
      (c.id = 7 AND l.id = 6) OR
      (c.id = 8 AND l.id = 7) OR
      (c.id = 9 AND l.id = 7) OR
      (c.id = 10 AND l.id = 8);

-- RelatedTo (Персонажи → Персонажи)
INSERT INTO RelatedTo ($from_id, $to_id, relationship_type)
SELECT c1.$node_id, c2.$node_id, 
       CASE 
           WHEN c1.id = 1 AND c2.id = 2 THEN 'Друг'
           WHEN c1.id = 1 AND c2.id = 3 THEN 'Друг'
           WHEN c1.id = 4 AND c2.id = 5 THEN 'Семья'
           WHEN c1.id = 6 AND c2.id = 7 THEN 'Союзник'
           WHEN c1.id = 8 AND c2.id = 9 THEN 'Семья'
           ELSE 'Друг'
       END
FROM Character c1, Character c2
WHERE (c1.id = 1 AND c2.id IN (2, 3)) OR
      (c1.id = 4 AND c2.id = 5) OR
      (c1.id = 6 AND c2.id = 7) OR
      (c1.id = 8 AND c2.id = 9);

-- Mentions (Книга → Локация)
INSERT INTO Mentions ($from_id, $to_id)
SELECT b.$node_id, l.$node_id
FROM Book b, Location l
WHERE (b.id = 1 AND l.id = 11) OR
      (b.id = 10 AND l.id = 11) OR
      (b.id = 6 AND l.id = 12) OR
      (b.id = 8 AND l.id = 12);

-- Запросы с MATCH 
-- 1. Найти все книги, где появляется персонаж
SELECT b.title AS Книга
FROM Character c, AppearsIn ai, Book b
WHERE MATCH(c-(ai)->b)
AND c.name = 'Гарри Поттер';

-- 2. Найти всех персонажей, посещавших локацию
SELECT c.name AS Персонаж, l.name AS Локация
FROM Character c, VisitedBy vb, Location l
WHERE MATCH(c-(vb)->l)
AND l.name = 'Хогвартс';

-- 3. Найти связи между персонажами
SELECT c1.name AS Персонаж1, c2.name AS Персонаж2, r.relationship_type AS Тип_связи
FROM Character c1, RelatedTo r, Character c2
WHERE MATCH(c1-(r)->c2);

-- 4. Найти книги, связанные через общие локации
SELECT 
    b1.title AS Книга1, 
    b2.title AS Книга2, 
    l.name AS Общая_локация
FROM Book b1, LocatedIn li1, Location l, LocatedIn li2, Book b2
WHERE MATCH(b1-(li1)->l<-(li2)-b2)
AND b1.id < b2.id
ORDER BY b1.title, b2.title;

-- 5. Найти персонажей из одной книги с рейтингом выше 4.7
SELECT c.name AS Персонаж, b.title AS Книга, b.rating AS Рейтинг
FROM Character c, AppearsIn ai, Book b
WHERE MATCH(c-(ai)->b)
AND b.rating > 4.7;

-- Запросы с SHORTEST_PATH 
-- 1. Найти кратчайший путь между персонажами через книги (шаблон "+")
SELECT *
FROM (
    SELECT 
        c1.name AS Начало,
        STRING_AGG(b.title, ' -> ') WITHIN GROUP (GRAPH PATH) AS Путь,
        LAST_VALUE(c2.name) WITHIN GROUP (GRAPH PATH) AS Конец
    FROM 
        Character AS c1,
        AppearsIn FOR PATH AS ai,
        Book FOR PATH AS b,
        AppearsIn FOR PATH AS ai2,
        Character FOR PATH AS c2
    WHERE MATCH(SHORTEST_PATH(c1(-(ai)->b<-(ai2)-c2)+))
      AND c1.name = 'Гарри Поттер'
) AS путь
WHERE путь.Конец = 'Гермиона Грейнджер';

-- 2. Найти связи между книгами через локации (шаблон "{1,3}")
WITH PathResults AS (
    SELECT 
        Book1.title AS StartTitle,
        STRING_AGG(Location.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS Path,
        LAST_VALUE(Book2.title) WITHIN GROUP (GRAPH PATH) AS EndTitle
    FROM 
        Book AS Book1,
        LocatedIn FOR PATH AS li,
        Location FOR PATH AS Location,
        LocatedIn FOR PATH AS li2,
        Book FOR PATH AS Book2  
    WHERE MATCH(SHORTEST_PATH(Book1(-(li)->Location<-(li2)-Book2){1,3}))
    AND Book1.title = 'Гарри Поттер и Философский камень'
)
SELECT StartTitle AS Начало, Path AS Локации, EndTitle AS Конец
FROM PathResults
WHERE EndTitle = '1984';


Select @@servername

-- Какие персонажи в каких книгах появляются?
SELECT 
    c.id AS IdFirst,
    c.name AS First,
    CONCAT('Character', c.id) AS [First image name],
    b.id AS IdSecond,
    b.title AS Second,
    CONCAT('Book', b.id) AS [Second image name],
    'appears_in' AS RelationshipType,
    1 AS Weight
FROM Character c, AppearsIn ai, Book b
WHERE MATCH(c-(ai)->b)

-- В каких локациях происходят события книг?
SELECT 
    b.id AS IdFirst,
    b.title AS First,
    CONCAT('Book', b.id) AS [First image name],
    l.id AS IdSecond,
    l.name AS Second,
    CONCAT('Location', l.id) AS [Second image name],
    'located_in' AS RelationshipType,
    1 AS Weight
FROM Book b, LocatedIn li, Location l
WHERE MATCH(b-(li)->l)

-- Какие персонажи какие места посещали?
SELECT 
    c.id AS IdFirst,
    c.name AS First,
    CONCAT('Character', c.id) AS [First image name],
    l.id AS IdSecond,
    l.name AS Second,
    CONCAT('Location', l.id) AS [Second image name],
    'visited' AS RelationshipType,
    vb.visit_count AS Weight
FROM Character c, VisitedBy vb, Location l
WHERE MATCH(c-(vb)->l)

-- Как персонажи связаны между собой?
SELECT 
    c1.id AS IdFirst,
    c1.name AS First,
    CONCAT('Character', c1.id) AS [First image name],
    c2.id AS IdSecond,
    c2.name AS Second,
    CONCAT('Character', c2.id) AS [Second image name],
    rt.relationship_type AS RelationshipType,
    CASE 
        WHEN rt.relationship_type = 'Друг' THEN 1
        WHEN rt.relationship_type = 'Семья' THEN 2
        WHEN rt.relationship_type = 'Союзник' THEN 3
        ELSE 1
    END AS Weight
FROM Character c1, RelatedTo rt, Character c2
WHERE MATCH(c1-(rt)->c2)

-- Какие книги упоминают общие локации?
SELECT 
    b.id AS IdFirst,
    b.title AS First,
    CONCAT('Book', b.id) AS [First image name],
    l.id AS IdSecond,
    l.name AS Second,
    CONCAT('Location', l.id) AS [Second image name],
    'mentions' AS RelationshipType,
    1 AS Weight
FROM Book b, Mentions m, Location l
WHERE MATCH(b-(m)->l)