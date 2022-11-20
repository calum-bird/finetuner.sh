-- This script was generated by the Schema Diff utility in pgAdmin 4
-- For the circular dependencies, the order in which Schema Diff writes the objects is not very sophisticated
-- and may require manual changes to the script to ensure changes are applied in the correct order.
-- Please report an issue for any failure with the reproduction steps.

DROP FUNCTION IF EXISTS public.request_job();

CREATE OR REPLACE FUNCTION public.request_job()
    RETURNS record
    LANGUAGE 'sql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100
    
AS $BODY$
   with latest_queue as (
     select * from public.queue pq
     where (pq.status = 0)
     order by pq.created_at asc
     limit 1
   )
   update public.queue q
   SET status = 1, status_change_at = NOW()
   FROM (
      select lq.*, sobj.name as jsonl_file_path from latest_queue lq left join storage.objects sobj ON sobj.id = lq.jsonl
   ) latest_queue
   WHERE latest_queue.id = q.id
   RETURNING latest_queue.*;
 
$BODY$;
