-- DROP DATABASE IF EXISTS portal_de_Artigos

-- CREATE DATABASE portal_de_artigos

-- \c portal_de_artigos

DROP SCHEMA IF EXISTS portal;
CREATE SCHEMA portal;

DROP SCHEMA IF EXISTS interacao;
CREATE SCHEMA interacao;

SET search_path TO public, portal, interacao;

CREATE TABLE portal.Usuario (
  id SERIAL PRIMARY KEY,
  email VARCHAR(100) UNIQUE NOT NULL,
  nome VARCHAR(100) NOT NULL,
  senha VARCHAR(100) NOT NULL,
  data_cadastro DATE NOT NULL,
  data_nascimento DATE NOT NULL,
  endereco_cep CHAR(8),
  endereco_rua VARCHAR(100),
  endereco_bairro VARCHAR(50),
  endereco_complemento VARCHAR(50),
  endereco_numero VARCHAR(10)
);

CREATE TABLE portal.telefone_usuario (
  id SERIAL PRIMARY KEY,
  numero CHAR(11) NOT NULL,
  usuario_id INT REFERENCES Usuario(id)
);

CREATE TABLE portal.Categoria (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL
);

CREATE TABLE portal.Artigo (
  id SERIAL PRIMARY KEY,
  titulo VARCHAR(200) NOT NULL,
  data_hora_publicacao timestamp,
  categoria_id INT REFERENCES Categoria(id)
);

CREATE TABLE portal.artigo_usuario (
  artigo_id INT REFERENCES Artigo(id),
  usuario_id INT REFERENCES Usuario(id),
  PRIMARY KEY (artigo_id, usuario_id)
);

CREATE TABLE interacao.Comentario (
  id SERIAL PRIMARY KEY,
  conteudo TEXT,
  data_hora timestamp,
  usuario_id INT REFERENCES Usuario(id),
  artigo_id INT REFERENCES Artigo(id)
);

CREATE TABLE interacao.Curtida (
  data_hora timestamp,
  usuario_id INT REFERENCES Usuario(id),
  artigo_id INT REFERENCES Artigo(id),
  PRIMARY KEY (usuario_id, artigo_id) -- um usuário só pode curtir um determinado artigo uma vez
);

INSERT INTO Usuario (
  email, nome, senha, data_cadastro, data_nascimento,
  endereco_cep, endereco_rua, endereco_bairro, endereco_complemento, endereco_numero)
VALUES
('fulano@gmail.com', 'Fulano da Silva', 'senha123', '2024-01-01', '1990-05-15', '11111000', 'Rua das Flores', 'Centro', 'Apto 101', 100),
('beltrana@gmail.com', 'Beltrana Oliveira', 'senha456', '2024-02-15', '1985-08-20', '22222000', 'Avenida Brasil', 'Bela Vista', '', 200);

INSERT INTO Usuario (
email, nome, senha, data_cadastro, data_nascimento)
VALUES
('ciclano@gmail.com', 'Ciclano Mendes', 'senha123', '2024-01-01', '1990-05-15');


INSERT INTO telefone_usuario (usuario_id, numero) VALUES
(1, '53911111111'),
(1, '53922222222'),
(2, '53933333333');

INSERT INTO Categoria (nome) VALUES
('Tecnologia'),
('Culinária'),
('Educação');

INSERT INTO Artigo (titulo, data_hora_publicacao, categoria_id) VALUES
('Aprendendo SQL', '2024-03-01 10:00:00', 1),
('Tutorial Java', '2024-03-01 15:00:00', 1);

INSERT INTO artigo_usuario (artigo_id, usuario_id) VALUES 
(1, 1),
(1, 2),
(2, 1),
(2, 2);

INSERT INTO Comentario (Conteudo, data_hora, usuario_id, artigo_id) VALUES
('Nossa, nunca li algo tão horrendo.', '2024-03-01 11:00:00', 2, 1),
('Burro. nao. sabe. iscreve.', '2024-03-05 16:00:00', 3, 2);

INSERT INTO Curtida (data_hora, usuario_id, artigo_id) VALUES
('2024-03-01 11:30:00', 2, 1),
('2024-03-05 16:30:00', 1, 2);


-- Quais usuários escreveram mais artigos? Em caso de empate mostrar todos.
CREATE VIEW artigos_por_usuario AS
SELECT usuario_id, COUNT(*) AS total_artigos
FROM artigo_usuario
GROUP BY usuario_id;

SELECT Usuario.nome, total_artigos
FROM  artigos_por_usuario
INNER JOIN Usuario ON artigos_por_usuario.usuario_id = Usuario.id
WHERE total_artigos = (SELECT MAX(total_artigos) FROM artigos_por_usuario);

-- O título de cada Artigo e o nome de cada usuário envolvido na escrita de cada Artigo
SELECT Artigo.titulo, Usuario.nome AS autor
FROM Artigo
INNER JOIN artigo_usuario ON Artigo.id = artigo_usuario.artigo_id
INNER JOIN Usuario ON artigo_usuario.usuario_id = Usuario.id;

-- Listar os Usuários com e sem endereços. Caso tenha endereço, coloque o endereço.
-- Se não tiver, coloque "Sem endereço cadastrado"
SELECT Usuario.id, Usuario.nome,
  CASE
    WHEN Usuario.endereco_rua IS NOT NULL THEN 
      CONCAT('Rua ', Usuario.endereco_rua,
        ', Número ', Usuario.endereco_numero,
        ', Bairro ', Usuario.endereco_bairro,
        ', Complemento ', Usuario.endereco_complemento,
        ', CEP ', Usuario.endereco_cep)
    ELSE 
      'Sem endereço cadastrado'
  END AS endereco
FROM Usuario;