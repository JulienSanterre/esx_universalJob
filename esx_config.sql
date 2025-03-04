INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_Tabac','Marlboro',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_Tabac','Marlboro',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_Tabac', 'Marlboro', 1)
;

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
('Tabac', 'Marlboro', 1);

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('Tabac',0,'recrue','Tabagiste Marlboro',400,'{}','{}'),
  ('Tabac',1,'gerant','Gérant Marlboro',650,'{}','{}'),
  ('Tabac',2,'boss','Patron Marlboro',800,'{}','{}');

INSERT INTO `items` (name, label) VALUES
  ('tabacblond', 'Tabac Blond'),
  ('tabacblondsec', 'Tabac Blond Séché'),
  ('malbora', 'Marlboro');
  
## For custom DB
  
  #INSERT INTO `items` (name, label, `limit`, price, weight, can_remove, storeId) VALUES
  #('tabacblond', 'Tabac Blond', 50, 8, 0.5, 1, 3),
  #('tabacblondsec', 'Tabac Blond Séché', 25, 15, 0.25, 1, 99),
  #('malbora', 'Marlboro', 12, 35, 0.1, 1, 99);
