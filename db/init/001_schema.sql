CREATE TABLE fuentes (
  id        SERIAL PRIMARY KEY,
  nombre    TEXT UNIQUE NOT NULL,
  url_base  TEXT NOT NULL,
  tipo      TEXT NOT NULL CHECK (tipo IN ('scraping','api')),
  activa    BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE ofertas (
  id                BIGSERIAL PRIMARY KEY,
  fuente_id         INT NOT NULL REFERENCES fuentes(id),
  url               TEXT UNIQUE NOT NULL,
  hash_dedup        CHAR(64) UNIQUE NOT NULL,
  empresa           TEXT,
  cargo             TEXT NOT NULL,
  descripcion       TEXT,
  modalidad         TEXT CHECK (modalidad IN ('remota','hibrida','presencial')),
  ciudad            TEXT,
  vinculacion       TEXT,
  salario_texto     TEXT NOT NULL DEFAULT 'No publicado',
  salario_min       NUMERIC(12,2),
  moneda            CHAR(3),
  fecha_publicacion DATE,
  fecha_recoleccion TIMESTAMPTZ NOT NULL DEFAULT now(),
  puntaje           SMALLINT CHECK (puntaje BETWEEN 0 AND 100),
  tipo              TEXT CHECK (tipo IN ('operativo','devops_cloud','otro')),
  motivo            TEXT
);
CREATE INDEX idx_ofertas_puntaje ON ofertas (puntaje DESC);
CREATE INDEX idx_ofertas_recoleccion ON ofertas (fecha_recoleccion DESC);

CREATE TABLE postulaciones (
  id          BIGSERIAL PRIMARY KEY,
  oferta_id   BIGINT UNIQUE NOT NULL REFERENCES ofertas(id) ON DELETE CASCADE,
  fecha       DATE NOT NULL DEFAULT CURRENT_DATE,
  estado      TEXT NOT NULL DEFAULT 'por_postular' CHECK (estado IN
              ('por_postular','postulado','entrevista','prueba_tecnica','oferta','rechazado')),
  notas       TEXT,
  actualizado TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ejecuciones (
  id             BIGSERIAL PRIMARY KEY,
  fuente_id      INT REFERENCES fuentes(id),
  inicio         TIMESTAMPTZ NOT NULL DEFAULT now(),
  fin            TIMESTAMPTZ,
  ofertas_nuevas INT NOT NULL DEFAULT 0,
  errores        TEXT
);

INSERT INTO fuentes (nombre, url_base, tipo) VALUES
  ('linkedin',     'https://www.linkedin.com/jobs',  'scraping'),
  ('computrabajo', 'https://co.computrabajo.com',    'scraping'),
  ('elempleo',     'https://www.elempleo.com/co',    'scraping');
