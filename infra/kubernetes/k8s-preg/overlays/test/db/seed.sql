INSERT INTO pills (name, type_pill, amount)
VALUES
  ('Aspirin', 'default', 1),
  ('Ibuprofen', 'default', 1)
ON CONFLICT DO NOTHING;
