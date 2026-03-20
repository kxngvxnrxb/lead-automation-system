-- =========================
-- Lead Automation System Schema
-- =========================

-- =========================
-- Trigger Function: set_updated_at
-- =========================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- Table: leads
-- =========================
CREATE TABLE IF NOT EXISTS public.leads (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  lead_key TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'typeform',
  send_mode TEXT NOT NULL DEFAULT 'test',
  first_name TEXT NULL,
  last_name TEXT NULL,
  email TEXT NULL,
  phone TEXT NULL,
  company TEXT NULL,
  website TEXT NULL,
  domain TEXT NULL,
  industry TEXT NULL,
  service TEXT NULL,
  budget_raw TEXT NULL,
  budget_usd INTEGER NULL,
  budget_bucket TEXT NULL,
  description TEXT NULL,
  utm_source TEXT NULL,
  utm_medium TEXT NULL,
  utm_campaign TEXT NULL,
  typeform_form_id TEXT NULL,
  typeform_token TEXT NULL,
  landed_at TIMESTAMPTZ NULL,
  submitted_at TIMESTAMPTZ NULL,
  status TEXT NOT NULL DEFAULT 'queued',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  score INTEGER NULL,
  score_reasons TEXT[] NULL DEFAULT '{}'::text[],
  thread_id TEXT NULL,
  last_email_sent_at TIMESTAMP NULL,
  last_reply_at TIMESTAMP NULL,
  followup_count INTEGER NULL DEFAULT 0,
  CONSTRAINT leads_pkey PRIMARY KEY (id),
  CONSTRAINT leads_lead_key_key UNIQUE (lead_key)
) TABLESPACE pg_default;

-- Indexes for leads
CREATE INDEX IF NOT EXISTS idx_leads_email ON public.leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_domain ON public.leads(domain);
CREATE INDEX IF NOT EXISTS idx_leads_status ON public.leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON public.leads(created_at);
CREATE INDEX IF NOT EXISTS idx_leads_status_created ON public.leads(status, created_at);

-- Trigger for updating updated_at
CREATE TRIGGER trg_leads_updated_at
BEFORE UPDATE ON public.leads
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================
-- Table: lead_events
-- =========================
CREATE TABLE IF NOT EXISTS public.lead_events (
  id BIGSERIAL NOT NULL,
  lead_id UUID NULL,
  lead_key TEXT NULL,
  event_type TEXT NOT NULL,
  meta JSONB NOT NULL DEFAULT '{}'::jsonb,
  run_id TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT lead_events_pkey PRIMARY KEY (id),
  CONSTRAINT lead_events_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE SET NULL
) TABLESPACE pg_default;

-- Indexes for lead_events
CREATE INDEX IF NOT EXISTS idx_lead_events_lead_id ON public.lead_events(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_events_event_type ON public.lead_events(event_type);
CREATE INDEX IF NOT EXISTS idx_lead_events_created_at ON public.lead_events(created_at);

-- =========================
-- Table: error_logs
-- =========================
CREATE TABLE IF NOT EXISTS public.error_logs (
  id BIGSERIAL NOT NULL,
  workflow_name TEXT NULL,
  node_name TEXT NULL,
  lead_key TEXT NULL,
  lead_id UUID NULL,
  error_message TEXT NULL,
  meta JSONB NOT NULL DEFAULT '{}'::jsonb,
  run_id TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT error_logs_pkey PRIMARY KEY (id)
) TABLESPACE pg_default;

-- Indexes for error_logs
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON public.error_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_error_logs_lead_key ON public.error_logs(lead_key);
