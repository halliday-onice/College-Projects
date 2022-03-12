create database if not exists universidade5;

use universidade5;

create table if not exists setor(
	cod_setor int(5) PRIMARY KEY NOT NULL,
    nome_setor varchar(25)
);
-- delete from setor where cod_setor = 55555;
-- delete from curso where cod_curso = 
select * from setor;

create table if not exists curso(
	cod_curso INT(5) PRIMARY KEY NOT NULL,
    nome_curso varchar(45),
    ano_inicio YEAR
);
select * from curso;

-- 1.8.4 inicio
DELIMITER $$

create trigger  Jubila_aluno after insert
on Media for each row
begin
	set @rep = (select count(situacao) from Media where(situacao = 'Reprovado' and cpf_aluno_media = new.cpf_aluno_media));
	
    if @rep >= 3 then
		update aluno set ativo = 'Não' where cpf_aluno = new.cpf_aluno_media;
	end if;

end$$
DELIMITER ;


-- select count(situacao) from Media where(situacao = 'Reprovado' and cpf_aluno_media = '177282');

insert into disciplina values(2782,'Fisica III',374638);
-- insert into disciplina values(4590,'Programacao I',128393);
-- insert into disciplina values (7654,'Calculo I',374638);
-- insert into disciplina values(4531,'Microbiologia II',9382912);


select * from Inscricao_Disciplinas;
select * from Notas;
select * from Media;
select * from disciplina;
create view Aluno_situ as select * from Notas inner join Media on (Notas.cpf_aluno_notas = Media.cpf_aluno_media and Notas.cod_disc_Notas = Media.cod_disc_m);
select * from aluno;
select * from Aluno_situ;
create view Aluno_situFINAL as select * from aluno join Aluno_situ on aluno.cpf_aluno = Aluno_situ.cpf_aluno_Notas;
select * from Aluno_situFINAL;
select cpf_aluno,nome_aluno,situacao,ativo,cod_disc_m from Aluno_situFINAL;

insert into Inscricao_Disciplinas values(4531,'177282','2021-08-15');
insert into Inscricao_Disciplinas values(7654,'177282','2021-08-15');

insert into Notas values('177282',7654,6.0,5.5);
-- delete from Notas where cpf_aluno_Notas = '177282' and cod_disc_Notas = 7654;
-- delete from Media where cpf_aluno_media = '177282' and cod_disc_m = 7654;
-- Nadir que tem o cpf 177282 tem q estar com o campo Ativo = não

-- 1.8.4 fim


select * from administrativo;
create table administrativo(
	cpf_adm varchar(13) PRIMARY KEY NOT NULL,
    nome_adm varchar(60),
    endereco_adm varchar(50),
    salario_adm real(7,2) not null,
    cod_setor_adm int(5) not null,
    foreign key (cod_setor_adm) references setor (cod_setor)
    
);
select * from administrativo;

select * from prof;
select * from disciplina;
select * from aluno;

create table if not exists prof(
	
	cpf_prof varchar(13) NOT NULL,
    nome_prof varchar(60),
    telefone_prof varchar(12),
    endereco_prof varchar(50),
    data_contrat date,
    salario_prof real(7,2) not null,
    ativo varchar(4),
    cod_curso_prof int(5) not null,
    primary key(cpf_prof,cod_curso_prof),
    foreign key (cod_curso_prof) references curso (cod_curso)
);
show tables;
create table if not exists aluno(
	cpf_aluno varchar(13) PRIMARY KEY NOT NULL,
    nome_aluno varchar(60),
    telefone_aluno varchar(12),
    endereco_aluno varchar(50),
    ativo varchar(4)
);
alter table aluno add(
	cod_curso_matric int(5),
    foreign key(cod_curso_matric) references curso (cod_curso)

);

alter table aluno modify cod_curso_matric int(5) not null;
describe aluno;

insert into aluno values('1281921','Juan Cabelero','98821213','Avenida dos normais','sim',1234);

select * from aluno;


create table if not exists Inscricao_curso(
	cpf_aluno_curso varchar(13),
    cod_curso_aluno int(5),
    
    primary key(cpf_aluno_curso,cod_curso_aluno),
    
    foreign key (cpf_aluno_curso) references aluno (cpf_aluno),
    foreign key (cod_curso_aluno) references curso (cod_curso)
	

);
show tables;

create table if not exists disciplina(
	cod_disc int(4) primary key not null,
    nome_disciplina varchar(55),
    cpf_prof_disc varchar(13),
    foreign key (cpf_prof_disc) references prof (cpf_prof)
    
);

create table if not exists RCurso_disciplina(
	cod_do_curso int(5),
    codigo_disciplina int(5),
    
    primary key(cod_do_curso,codigo_disciplina),
    
    foreign key (cod_do_curso) references curso (cod_curso),
    foreign key (codigo_disciplina) references disciplina(cod_disc) 
);

describe RCurso_disciplina;

 insert into RCurso_disciplina values(1234,2782);
 insert into RCurso_disciplina values(8593,4590);
 insert into RCurso_disciplina values(8593,7654);
 insert into RCurso_disciplina values(3415,4531);
show tables;

create table if not exists Inscricao_Disciplinas(
	codigo_insc int(4) not null,
    cpf_aluno_insc varchar(13) NOT NULL,
    data_insc date,
    -- ter algo que vincule a um curso...
    primary key(codigo_insc,cpf_aluno_insc),
    foreign key (cpf_aluno_insc) references aluno (cpf_aluno),
    foreign key (codigo_insc) references disciplina (cod_disc)
    
    
);
select * from disciplina;

select * from Inscricao_Disciplinas;

select * from aluno;
-- +++++++++++++++++++++++++++++++++++++++++++++++++ INSERCOES E QUERYS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into setor values(1234,'Secretaria');
insert into setor values(1356,'Acadêmico');
insert into setor values (2811,'Recursos Humanos');


-- insert curso
describe curso;
insert into curso values(1234,'Engenharia Nuclear',2006);
insert into curso values(8593,'Engenharia de Computação',2014);
insert into curso values(1235,'Medicina',1967);
insert into curso values (3415,'Farmácia',2011);

-- insert dos funcionarios administrativos
select * from setor;
select * from administrativo;
insert into administrativo values ('8595834','Kratos Dasgard','Rua dos bobs numero 0',4854.90,2811);
insert into administrativo values ('9382712','Artreus Sonnerson','Avenida dos reis',2784.90,1356);
insert into administrativo values ('463723','Freya Absurdios Noloch','Rua do Imperador',2498.90,1234);
insert into administrativo values ('8493723','Tortuguito Animales','Rua dos bobos numero 1',1898.90,2811);

-- insert nos alunos


insert into aluno values ("177282","Nadir Eduarda Pereira","93883922","Rua dos bobos","sim",1234);
insert into aluno values ("9837392","Natuza Nery","9882637","Jardim Botanico n 564","sim",1235);
insert into aluno values("2993829","Octavio Mendes Guedes","9928726","Rua proerd n 63","sim",1235);
insert into aluno values("3989221","Andrea Surtrapi Souza","2902830","Avenida das Americas n 32","sim",8593);
insert into aluno values("8437213","Marcos Rogério Assin","98829131","Avenida do Senado","sim",1235);



-- insert dos professores

insert into prof values(128393,"Alberto Hernandes",126271,"Avenida dos maneiros",'2008-09-13',6747.98,'sim',1234);
insert into prof values(374638,"Eduardo Macedo Loksvoski",984437263,"Rua dos alfeneiros 23",'2011-03-21',7566.67,'sim',8593);
insert into prof values(241290,"Maria Albuquerque Xavier",987765121,"Rua dos ouvidores 78",'2015-07-11',5698.67,'sim',8593);
insert into prof values(836272,"Felipe Acker Duarte",987765121,"Rua dos malucos ",'2012-05-09',4500.67,'sim',1235);
insert into prof values(6372811,'Marluce Souza Minuta','387292212','Avenida dos loucos','2016-07-15',5673.87,'sim',1234);
insert into prof values(9382912,'Antonio Goes','983728212','Rua projetada A','2017-08-11',4768.90,'sim',3415);

-- insert das disciplinas
describe disciplina;
insert into disciplina values(2782,'Fisica III',374638);
insert into disciplina values(4590,'Programacao I',128393);
insert into disciplina values (7654,'Calculo I',374638);
insert into disciplina values(4531,'Microbiologia II',9382912);



-- inserts de inscricao em disciplinas
select * from aluno;
describe Inscricao_Disciplinas;



-- item 1.7 inicio
describe Inscricao_Disciplinas;
insert into Inscricao_Disciplinas values(4590,'177282','2021-08-15');
insert into Inscricao_Disciplinas values(7654,'177282','2021-08-16');
insert into Inscricao_Disciplinas values(7654,'8437213','2021-09-11');
insert into Inscricao_Disciplinas values(4531,'8437213','2021-08-13');


select * from Inscricao_Disciplinas;


insert into Notas values('8437213',4531,6,6);
insert into Notas values('177282',4590,5.8,7.0);
insert into Notas values('177282',7654,9.6,8.0);
insert into Notas values('8437213',7654,6.5,6.0);





-- fim item 1.7



-- 1.8.1 inicio
describe disciplina;
-- fazer join com a Inscricao-Disciplinas e a disciplina pra pegar o nome da disciplina

create view Qdadeporturma as select * from disciplina join Inscricao_Disciplinas on disciplina.cod_disc = Inscricao_Disciplinas.codigo_insc;
select * from Qdadeporturma;
create view PrintarQdadeT as select count(cpf_aluno_insc) as qdadeturma,nome_disciplina as nome_turma from Qdadeporturma group by nome_disciplina order by qdadeturma desc;
-- nao sei se ele vai reclamar porque meio q estou fazendo pelo nome da disciplina
select max(qdadeturma) qdade_por_turma,nome_turma from PrintarQdadeT group by nome_turma;

-- 1.8.1 fim



select * from RCurso_disciplina;

select * from prof;

-- 1.8.2 inicio



create view ProfsAtivos as select * from prof where(prof.ativo = 'sim');
select * from ProfsAtivos;
create view ITEM182 as select * from ProfsAtivos  join curso on ProfsAtivos.cod_curso_prof = curso.cod_curso;
select * from ITEM182;

select count(cpf_prof) as qdadeprofcurso,nome_curso from ITEM182 group by nome_curso order by qdadeprofcurso;


-- fim 1.8.2



-- 1.8.3 inicio

create view ProfsAtivos as select * from prof where(prof.ativo = 'sim');
create view ITEM182 as select * from ProfsAtivos  join curso on ProfsAtivos.cod_curso_prof = curso.cod_curso;


select * from prof;

select * from ITEM182;

select avg(salario_prof),nome_curso from ITEM182 group by nome_curso;

-- 1.8.3 fim


-- 1.8.4 inicio
DELIMITER $$

create trigger  Jubila_aluno after insert
on Media for each row
begin
	set @rep = (select count(situacao) from Media where(situacao = 'Reprovado' and cpf_aluno_media = new.cpf_aluno_media));
	
    if @rep >= 3 then
		update aluno set ativo = 'Não' where cpf_aluno = new.cpf_aluno_media;
	end if;

end$$
DELIMITER ;


-- select count(situacao) from Media where(situacao = 'Reprovado' and cpf_aluno_media = '177282');

insert into disciplina values(2782,'Fisica III',374638);
-- insert into disciplina values(4590,'Programacao I',128393);
-- insert into disciplina values (7654,'Calculo I',374638);
-- insert into disciplina values(4531,'Microbiologia II',9382912);

select * from prof;
select * from Inscricao_Disciplinas;
select * from Notas;
select * from Media;
select * from disciplina;
create view Aluno_situ as select * from Notas inner join Media on (Notas.cpf_aluno_notas = Media.cpf_aluno_media and Notas.cod_disc_Notas = Media.cod_disc_m);
select * from aluno;
select * from Aluno_situ;
create view Aluno_situFINAL as select * from aluno join Aluno_situ on aluno.cpf_aluno = Aluno_situ.cpf_aluno_Notas;
select * from Aluno_situFINAL;
select cpf_aluno,nome_aluno,situacao,ativo,cod_disc_m from Aluno_situFINAL;

insert into Inscricao_Disciplinas values(4531,'177282','2021-08-15');
insert into Inscricao_Disciplinas values(7654,'177282','2021-08-15');

insert into Notas values('177282',7654,6.0,5.5);
-- delete from Notas where cpf_aluno_Notas = '177282' and cod_disc_Notas = 7654;
-- delete from Media where cpf_aluno_media = '177282' and cod_disc_m = 7654;
-- Nadir que tem o cpf 177282 tem q estar com o campo Ativo = não

-- 1.8.4 fim



-- 1.8.5 inicio


create view SetorAdm as select * from administrativo join setor on administrativo.cod_setor_adm = setor.cod_setor;
select * from SetorAdm;

select sum(salario_adm) as soma_salario,nome_setor from SetorAdm group by nome_setor order by soma_salario desc;


-- 1.8.5 fim


-- 1.8.6 inicio
select * from Qdadeporturma;
select * from Notas;
select * from Media join Qdadeporturma on (Qdadeporturma.cod_disc = Media.cod_disc_m and Qdadeporturma.cpf_aluno_insc = Media.cpf_aluno_media);

create view Media_alunos_turma as select * from Media join Qdadeporturma on (Qdadeporturma.cod_disc = Media.cod_disc_m and Qdadeporturma.cpf_aluno_insc = Media.cpf_aluno_media);

select * from Media_alunos_turma;

select * from Inscricao_Disciplinas;
select * from prof;
select * from disciplina;

create view Media_final_disc as select avg(Media_final) as Media_final_turmas,nome_disciplina,cod_disc from Media_alunos_turma group by cod_disc;
select * from Media_final_disc;
select * from disciplina;
create view Media_geral_turmas as select disciplina.cod_disc,disciplina.nome_disciplina,Media_final_turmas,cpf_prof_disc from disciplina  join Media_final_disc on disciplina.cod_disc = Media_final_disc.cod_disc;
select * from Media_geral_turmas;

select cod_disc,nome_disciplina,nome_prof,Media_final_turmas from Media_geral_turmas join prof on Media_geral_turmas.cpf_prof_disc = prof.cpf_prof;


-- 1.8.6 fim




select * from Qdadeporturma;
select * from aluno;

-- vou tentar a partir daqui fazer uma tabela que calcule a media
create table if not exists Notas(
	cpf_aluno_Notas varchar(13),
    cod_disc_Notas int(4),
    N1 real(2,1),
    N2 real(2,1),
    
    
    primary key(cpf_aluno_Notas,cod_disc_Notas),
    
    foreign key(cpf_aluno_Notas) references aluno (cpf_aluno),
    foreign key(cod_disc_Notas) references disciplina(cod_disc)

);

create table if not exists Media(
	cpf_aluno_media varchar(13),
    cod_disc_m int(4),
    Media_final real(8,6),
    situacao varchar(15),
    
    primary key(cpf_aluno_media,cod_disc_m),
    
    foreign key (cpf_aluno_media) references aluno (cpf_aluno),
    foreign key (cod_disc_m) references disciplina (cod_disc)
	

);




select * from Notas;
-- delete from Notas where cpf_aluno_Notas = '9837392';

-- delete from Media where cpf_aluno_media = '9837392' and cod_disc_m = 4531;
select * from Inscricao_Disciplinas;


DELIMITER $$
create trigger Calcula_media_nota after insert 
on Notas
for each row
begin
	
    set @media_final = (select avg((new.N1 + new.N2)/2) from Notas);
     -- update Media set Media_final = 10 where (cpf_aluno_media = new.cpf_aluno_Notas and cod_disc_m = new.cod_disc_Notas);
	if @media_final >= 7 then
		insert into Media values(new.cpf_aluno_Notas,new.cod_disc_Notas,@media_final,'Aprovado');
	
	else 
		insert into Media values(new.cpf_aluno_Notas,new.cod_disc_Notas,@media_final,'Reprovado');
	end if;
end$$
DELIMITER ;


describe Notas;
describe Media;
select * from Notas;
select * from Media;
show triggers;


select * from Inscricao_Disciplinas;



select * from Notas;
select * from Media;


-- DELETAR REGISTROS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- delete from Notas;
-- delete from Media;
-- DELETAR REGISTROS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!









-- 1.8.7 inicio
select * from ITEM182;

select * from disciplina;

select * from RCurso_disciplina;

create view ITEM187 as select * from disciplina,RCurso_disciplina where disciplina.cod_disc = RCurso_disciplina.codigo_disciplina;
select * from ITEM187;

describe curso;
create view Qdadeprofscurso as select * from curso join ITEM187 on ITEM187.cod_do_curso = curso.cod_curso;

select * from Qdadeprofscurso;
select count(cod_curso) as qdadecurso,nome_curso from Qdadeprofscurso group by nome_curso order by qdadecurso;

create view Qntscursosprof as select count(cod_curso) as qdadecurso,cpf_prof_disc from Qdadeprofscurso group by cpf_prof_disc order by qdadecurso;

create view Profsemcursos as select * from Qntscursosprof join prof on Qntscursosprof.cpf_prof_disc = prof.cpf_prof;
select * from Profsemcursos;
select qdadecurso,nome_prof from Profsemcursos group by nome_prof,qdadecurso order by qdadecurso;
-- esse eh comando do 1.8.7


select * from prof;

-- 1.8.8 inicio
select min(data_contrat) from prof;


select nome_prof from prof where data_contrat = (select min(data_contrat) from prof);

-- 1.8.8 fim

-- 1.8.9 inicio
select * from RCurso_disciplina;

select * from curso;
select * from aluno;

create view Alunoscurso as select * from aluno join curso on aluno.cod_curso_matric = curso.cod_curso;
select * from Alunoscurso;
show tables;

-- select nome_aluno,endereco_aluno from Alunoscurso group by cod_curso_matric; isso aqui nem funciona
select * from aluno;
select count(cpf_aluno) as qdadealunos,nome_curso from Alunoscurso group by nome_curso;




-- 1.8.9 fim




