#Query find and resume mirrors in suspended state

select 'alter database '+db_name(database_id)+' set partner resume;' as dbname,mirroring_state_desc as status 
from sys.database_mirroring 
where mirroring_state is not null
and mirroring_state_desc = 'SUSPENDED'