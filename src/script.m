clear
close all
  
option = 0;

        results1 = hr_arousal_glutamate_bulk(.5,.5);
        results10 = hr_arousal_glutamate_bulk(5,5);
        results30 = hr_arousal_glutamate_bulk(15,15);
        save('resultsLM_june19')  
