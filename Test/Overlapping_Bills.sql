
with cte_openBills as
(
select p.Alt_Identifier MPID, pb.recon_date, trunc((pb.recon_date),'month') grace_first_of_month
,Trans_id, pb.key_value, pb.billing_cycle_id, pb.Invoice_Date
, pb.due_date, pb.premium_total,pb.inserted_date, pb.coverage_start, pb.coverage_stop, pb.invoice_start, pb.invoice_stop
, tr.trans_identifier
, tr.trans_type
, tr.activity_Date
, tr.trans_source
, tr.trans_status
from dbo.Premium_bill pb
inner join dbo.member m on pb.key_value = m.Member_id
inner join dbo.person p on m.Person_id = p.Person_Id
inner join dbo.transaction tr on m.Member_id = tr.Ref_key_1 and pb.Premium_Bill_ID = tr.Trans_Source_key
where pb.entity_id = 242
--and pb.due_date = '05/31/2022'
and tr.trans_source = 'AP' --active premium
and tr.trans_status = 'O' --closed
and pb.premium_total > 0
)
select * from cte_openBills a1
inner join cte_openBills a2 on a1.MPID = a2.MPID 
and a2.activity_Date between a1.grace_first_of_month and  a1.recon_date
and a2.Trans_id <> a1.Trans_id
order by a1.recon_date;

with cte_openBills as
(
select p.Alt_Identifier MPID, m.member_id,  pb.recon_date, trunc((pb.recon_date),'month') grace_first_of_month
,Trans_id, pb.key_value, pb.billing_cycle_id, pb.Invoice_Date
, pb.due_date, pb.premium_total,pb.inserted_date, pb.coverage_start, pb.coverage_stop, pb.invoice_start, pb.invoice_stop
, tr.trans_identifier
, tr.trans_type
, tr.activity_Date
, tr.trans_source
, tr.trans_status
from dbo.Premium_bill pb
inner join dbo.member m on pb.key_value = m.Member_id
inner join dbo.person p on m.Person_id = p.Person_Id
inner join dbo.transaction tr on m.Member_id = tr.Ref_key_1 and pb.Premium_Bill_ID = tr.Trans_Source_key
where pb.entity_id = 242
--and pb.due_date = '05/31/2022'
and tr.trans_source = 'AP' --active premium
and tr.trans_status = 'O' --closed
and pb.premium_total > 0
)
select * from cte_openBills a1
inner join dbo.eligibility e on a1.member_id = e.member_id and e.start_date = a1.coverage_stop + 1
where a1.Due_date = '30-Jun-2023' and a1.trans_type = '_POLADJ'
--and a1.coverage_stop = '31-Aug-2023'
and not exists (select 1 from cte_openBills a2 where a1.MPID = a2.MPID 
    and a2.Trans_id <> a1.Trans_id)
order by a1.recon_date;


