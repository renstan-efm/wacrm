-- ============================================================
-- check-migrations.sql — which database updates has this Supabase
-- project received?
--
-- READ-ONLY. It changes nothing. Paste it into the Supabase
-- dashboard → SQL Editor → Run.
--
-- The migrations in supabase/migrations/ are applied by hand, so the
-- database keeps no record of which ones ran. Instead, this looks for
-- one thing each migration creates (a table, column, function, etc).
-- Any row showing "MISSING" means that migration (or a later part of
-- it) has not been applied: run that file in the SQL Editor, in order.
-- Some later migrations only tighten security on existing functions,
-- so a database that skipped one can look "ok" on the earlier ones;
-- treat this as a strong hint, not a guarantee.
--
-- Keep this in step with supabase/migrations/ when new files are added.
-- ============================================================

WITH checks(migration, looks_for, ok) AS (
  VALUES
  ('001_initial_schema',               'table profiles',                         to_regclass('public.profiles') IS NOT NULL),
  ('002_pipelines_enhancements',       'column deals.assigned_to',               EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='deals' AND column_name='assigned_to')),
  ('003_broadcast_recipient_wamid',    'index idx_broadcast_recipients_wamid',   to_regclass('public.idx_broadcast_recipients_wamid') IS NOT NULL),
  ('004_contact_delete_set_null',      'broadcast contact link is ON DELETE SET NULL',
                                                                                 EXISTS (SELECT 1 FROM pg_constraint WHERE conname='broadcast_recipients_contact_id_fkey' AND confdeltype='n')),
  ('005_broadcast_counts_incremental', 'function _bcast_bump',                   EXISTS (SELECT 1 FROM pg_proc WHERE proname='_bcast_bump')),
  ('006_automations',                  'table automations',                      to_regclass('public.automations') IS NOT NULL),
  ('007_automations_increment_counter','function increment_automation_execution_count',
                                                                                 EXISTS (SELECT 1 FROM pg_proc WHERE proname='increment_automation_execution_count')),
  ('008_profile_avatars_storage',      'storage bucket avatars',                 EXISTS (SELECT 1 FROM storage.buckets WHERE id='avatars')),
  ('009_message_actions',              'table message_reactions',                to_regclass('public.message_reactions') IS NOT NULL),
  ('010_flows',                        'table flows',                            to_regclass('public.flows') IS NOT NULL),
  ('011_profile_beta_features',        'column profiles.beta_features',          EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='beta_features')),
  ('012_flows_increment_counter',      'function increment_flow_execution_count',EXISTS (SELECT 1 FROM pg_proc WHERE proname='increment_flow_execution_count')),
  ('013_whatsapp_config_phone_number_id_unique', 'unique phone_number_id',       EXISTS (SELECT 1 FROM pg_constraint WHERE conname='whatsapp_config_phone_number_id_key')),
  ('014_message_templates_meta_integration', 'column message_templates.meta_template_id',
                                                                                 EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='message_templates' AND column_name='meta_template_id')),
  ('015_whatsapp_config_registration', 'column whatsapp_config.registered_at',   EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='whatsapp_config' AND column_name='registered_at')),
  ('016_flow_media',                   'storage bucket flow-media',              EXISTS (SELECT 1 FROM storage.buckets WHERE id='flow-media')),
  ('017_account_sharing',              'table accounts',                         to_regclass('public.accounts') IS NOT NULL),
  ('018_account_member_rpcs',          'function set_member_role',               EXISTS (SELECT 1 FROM pg_proc WHERE proname='set_member_role')),
  ('019_invitation_rpcs',              'function redeem_invitation',             EXISTS (SELECT 1 FROM pg_proc WHERE proname='redeem_invitation')),
  ('020_account_sharing_followups',    'index idx_flows_account_active',         to_regclass('public.idx_flows_account_active') IS NOT NULL),
  ('021_account_default_currency',     'column accounts.default_currency',       EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='accounts' AND column_name='default_currency')),
  ('022_contact_phone_dedup',          'index idx_contacts_account_phone_normalized',
                                                                                 to_regclass('public.idx_contacts_account_phone_normalized') IS NOT NULL),
  ('023_chat_media',                   'storage bucket chat-media',              EXISTS (SELECT 1 FROM storage.buckets WHERE id='chat-media')),
  ('024_member_presence',              'table member_presence',                  to_regclass('public.member_presence') IS NOT NULL),
  ('025_filter_contacts_by_tags',      'function filter_contacts_by_tags',       EXISTS (SELECT 1 FROM pg_proc WHERE proname='filter_contacts_by_tags')),
  ('026_api_keys',                     'table api_keys',                         to_regclass('public.api_keys') IS NOT NULL),
  ('027_notifications',                'table notifications',                    to_regclass('public.notifications') IS NOT NULL),
  ('028_webhook_endpoints',            'table webhook_endpoints',                to_regclass('public.webhook_endpoints') IS NOT NULL),
  ('029_ai_reply',                     'table ai_configs',                       to_regclass('public.ai_configs') IS NOT NULL),
  ('030_ai_knowledge',                 'table ai_knowledge_documents',           to_regclass('public.ai_knowledge_documents') IS NOT NULL),
  ('031_ai_reply_slot_grant',          'bot may call claim_ai_reply_slot',       EXISTS (SELECT 1 FROM pg_proc p WHERE p.proname='claim_ai_reply_slot' AND has_function_privilege('service_role', p.oid, 'EXECUTE'))),
  ('032_fix_ai_knowledge_membership',  'knowledge search no longer bypasses security',
                                                                                 EXISTS (SELECT 1 FROM pg_proc WHERE proname='match_ai_knowledge_fts')
                                                                                 AND NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname IN ('match_ai_knowledge_fts','match_ai_knowledge_semantic') AND prosecdef)),
  ('033_ai_reply_polish',              'table ai_usage_log',                     to_regclass('public.ai_usage_log') IS NOT NULL),
  ('034_fix_profiles_update_rls',      'trigger enforce_profile_privilege_columns',
                                                                                 EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='enforce_profile_privilege_columns')),
  ('035_interactive_messages',         'table quick_replies',                    to_regclass('public.quick_replies') IS NOT NULL),
  ('036_conversation_contact_dedup',   'index idx_conversations_account_contact',to_regclass('public.idx_conversations_account_contact') IS NOT NULL),
  ('037_webhook_broadcast_reliability','index idx_messages_conversation_message_id',
                                                                                 to_regclass('public.idx_messages_conversation_message_id') IS NOT NULL),
  ('038_broadcast_resume',             'column broadcasts.delivery_locked_at',   EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='broadcasts' AND column_name='delivery_locked_at')),
  ('039_inbound_media_mirror',         'column whatsapp_config.mirror_inbound_media',
                                                                                 EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='whatsapp_config' AND column_name='mirror_inbound_media')),
  ('040_contact_business_scoped_user_id', 'column contacts.wa_user_id',          EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='contacts' AND column_name='wa_user_id')),
  -- 041 only rewrites a function that 049 replaces again, so it shares 049's check.
  ('041_fix_broadcast_contact_id_ambiguity', 'same check as 049',                EXISTS (SELECT 1 FROM pg_proc p WHERE p.proname='create_broadcast_with_recipients' AND p.pronargs=8 AND p.proargtypes[7]='jsonb'::regtype)),
  ('042_message_failure_reason',       'column messages.error_code',             EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='messages' AND column_name='error_code')),
  ('043_storage_scoped_select',        'policy "Users can read their own avatar"',
                                                                                 EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND policyname='Users can read their own avatar')),
  ('044_internal_definer_grants',      'logged-in users can no longer call _bcast_bump',
                                                                                 EXISTS (SELECT 1 FROM pg_proc p WHERE p.proname='_bcast_bump' AND NOT has_function_privilege('authenticated', p.oid, 'EXECUTE'))),
  ('045_automation_wait_for_reply',    'index idx_automation_pending_awaiting_reply',
                                                                                 to_regclass('public.idx_automation_pending_awaiting_reply') IS NOT NULL),
  ('046_ai_openai_compatible',         'column ai_configs.base_url',             EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='ai_configs' AND column_name='base_url')),
  ('047_account_membership_integrity', 'trigger enforce_account_identity_columns',
                                                                                 EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='enforce_account_identity_columns')),
  ('048_quick_reply_content_matches_kind', 'constraint quick_replies_content_matches_kind',
                                                                                 EXISTS (SELECT 1 FROM pg_constraint WHERE conname='quick_replies_content_matches_kind')),
  ('049_broadcast_params_jsonb',       'create_broadcast_with_recipients takes jsonb',
                                                                                 EXISTS (SELECT 1 FROM pg_proc p WHERE p.proname='create_broadcast_with_recipients' AND p.pronargs=8 AND p.proargtypes[7]='jsonb'::regtype)),
  -- (there is no 050 or 056 in the repo; the numbers were skipped upstream)
  ('051_automation_pending_integrity', 'column automation_pending_executions.claimed_at',
                                                                                 EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='automation_pending_executions' AND column_name='claimed_at')),
  ('052_flow_run_integrity',           'column flow_runs.transition_seq',        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='flow_runs' AND column_name='transition_seq')),
  ('053_ai_reply_integrity',           'new knowledge-search matching',          EXISTS (SELECT 1 FROM pg_proc WHERE proname='match_ai_knowledge_fts' AND prosrc LIKE '%tsvector_to_array%')),
  ('054_webhook_status_integrity',     'table pending_message_statuses',         to_regclass('public.pending_message_statuses') IS NOT NULL),
  ('055_authz_membership_holes',       'trigger enforce_conversation_assignee_membership',
                                                                                 EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='enforce_conversation_assignee_membership')),
  ('057_message_templates_account_unique', 'index message_templates_account_name_language_key',
                                                                                 to_regclass('public.message_templates_account_name_language_key') IS NOT NULL),
  ('058_engine_race_gaps',             'column broadcasts.delivery_lease_until', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='broadcasts' AND column_name='delivery_lease_until')),
  ('059_dashboard_overview',           'column accounts.reply_target_minutes',   EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='accounts' AND column_name='reply_target_minutes')),
  ('060_inbound_unsupported_reason',   'updated description on messages.error_code (labels only)',
                                                                                 EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid=to_regclass('public.messages') AND attname='error_code' AND col_description(attrelid, attnum) ILIKE '%unsupported%'))
)
SELECT migration,
       CASE WHEN ok THEN 'ok' ELSE 'MISSING' END AS status,
       looks_for
FROM checks
ORDER BY ok, migration;   -- anything MISSING floats to the top
