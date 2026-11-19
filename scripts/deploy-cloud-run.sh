#!/usr/bin/env bash
# Build a new wacrm image on Cloud Build and roll it out to Cloud Run.
#
#   scripts/deploy-cloud-run.sh v2        # build + deploy tag v2
#   scripts/deploy-cloud-run.sh v2 build  # build only
#
# The NEXT_PUBLIC_* build values are copied from the running Cloud Run
# service, so the new image always matches the live settings. Nothing
# secret is printed. Roll back with:
#   gcloud run services update-traffic wacrm --region africa-south1 \
#     --project wa-crm-eternalflame --to-revisions <old-revision>=100
set -euo pipefail

PROJECT=wa-crm-eternalflame
REGION=africa-south1
SERVICE=wacrm
TAG="${1:?usage: $0 <tag> [build]}"
IMAGE="$REGION-docker.pkg.dev/$PROJECT/wacrm/wacrm:$TAG"

cd "$(dirname "$0")/.."

env_json=$(gcloud run services describe "$SERVICE" --project "$PROJECT" --region "$REGION" \
  --format='json(spec.template.spec.containers[0].env)')
get() { python3 -I -c 'import json,sys
env=json.loads(sys.argv[1])["spec"]["template"]["spec"]["containers"][0]["env"]
print(next(e.get("value","") for e in env if e["name"]==sys.argv[2]))' "$env_json" "$1"; }

SUPABASE_URL=$(get NEXT_PUBLIC_SUPABASE_URL)
SUPABASE_ANON_KEY=$(get NEXT_PUBLIC_SUPABASE_ANON_KEY)
SITE_URL=$(get NEXT_PUBLIC_SITE_URL)
APP_LOCALE=$(get NEXT_PUBLIC_APP_LOCALE)
for v in SUPABASE_URL SUPABASE_ANON_KEY SITE_URL APP_LOCALE; do
  [ -n "${!v}" ] || { echo "Missing $v on the Cloud Run service; aborting." >&2; exit 1; }
done

echo "Building $IMAGE from commit $(git rev-parse --short HEAD) ..."
gcloud builds submit . --project "$PROJECT" --region "$REGION" --config cloudbuild.yaml \
  --substitutions="_IMAGE=$IMAGE,_SUPABASE_URL=$SUPABASE_URL,_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY,_SITE_URL=$SITE_URL,_APP_LOCALE=$APP_LOCALE" \
  --suppress-logs

[ "${2:-}" = build ] && { echo "Built $IMAGE (not deployed)."; exit 0; }

echo "Deploying $IMAGE to Cloud Run service $SERVICE ..."
gcloud run deploy "$SERVICE" --project "$PROJECT" --region "$REGION" --image "$IMAGE" --quiet
