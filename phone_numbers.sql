CREATE TABLE phone_numbers (
  id INTEGER NOT NULL,
  label CHARACTER VARYING(40) NOT NULL,
  num CHARACTER VARYING(40) NOT NULL,
  contact_id INTEGER NOT NULL
);

ALTER TABLE ONLY phone_numbers 
  ADD CONSTRAINT PRIMARY KEY(id),
  ADD CONSTRAINT contact_fkey FOREIGN KEY(contact_id) REFERENCES contact_list(id);