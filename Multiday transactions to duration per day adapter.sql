WITH T AS (
  select d.fulldate, 
  1.0*case 
  when convert(date,T.BeginDateTime) =  convert(date,T.EndDateTime) then datediff(minute,BeginDateTime,EndDateTime) -- all happens in one day
  when d.fulldate between dateadd(DAY,-1,T.BeginDateTime) and T.BeginDateTime then datediff(MINUTE,T.BeginDateTime,dateadd(DAY,1,d.fulldate)) -- first day - take duration from the transaction begin till the end of the day
  when d.fulldate between dateadd(DAY,-1,T.EndDateTime) and T.EndDateTime then datediff(MINUTE,d.fulldate,T.EndDateTime) -- last day -  from begin of the day till the transaction end
  else  24*60  end/1440 as DURATION-- whole days 
  ,[BeginDateTime]
  ,[EndDateTime]
  ,TransactionName
  ,Car  
   --   ,any extra fields you need from your transactions 
   from [TRANSACTIONS] T
  inner join [dbo].[dim_date] D on D.fulldate between convert(date,T.BeginDateTime) and  convert(date,T.EndDateTime) 
  ) 

select fulldate
, DURATION
,[BeginDateTime]
,[EndDateTime]
,[MI_TRANSPORT_DURATION]= case when TransactionName ='Transport'   then DURATION else NULL end
,[MI_TRANSPORT_COUNT]=case when TransactionName ='Transport'   then 1 else NULL end
FROM  T
order by Car , fulldate

-- now you can plot duration, count and average  :)   = [MI_TRANSPORT_DURATION]/[MI_TRANSPORT_COUNT]
--  [dim_date]  is your date dimention, one record per day, fulldate is a field in datetime format
-- Duration will be in days, thus 0.5 means half day, or 12 hours. 

