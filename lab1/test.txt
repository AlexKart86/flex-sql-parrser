update chair_discipline
   set chair_id = 2,
       discipline_id = 234455+3,
       study_year_id = "2015/2016",
       notes = "some
	   long 
	   notes"
 where chair_id = 2
   and discipline_id <> 3
   and study_year_id = "2014/2016"
