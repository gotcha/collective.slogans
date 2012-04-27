$(document).ready(function() {
    $('.slogan').SetScroller({	
        velocity: 	 30,
        direction: 	 'horizontal',
        startfrom: 	 'right',
        loop:		 'infinite',
        movetype: 	 'linear',
        onmouseover: 'pause',
        onmouseout:  'play',
        onstartup: 	 'play',
        cursor: 	 'pointer'
    });
	/*
		All possible values for options...
		
		velocity: 		from 1 to 99 								[default is 50]						
		direction: 		'horizontal' or 'vertical' 					[default is 'horizontal']
		startfrom: 		'left' or 'right' for horizontal direction 	[default is 'right']
						'top' or 'bottom' for vertical direction	[default is 'bottom']
		loop:			from 1 to n+, or set 'infinite'				[default is 'infinite']
		movetype:		'linear' or 'pingpong'						[default is 'linear']
		onmouseover:	'play' or 'pause'							[default is 'pause']
		onmouseout:		'play' or 'pause'							[default is 'play']
		onstartup: 		'play' or 'pause'							[default is 'play']
		cursor: 		'pointer' or any other CSS style			[default is 'pointer']
	*/
    $(window).focus(function(){
        $('.slogan').PlayScroller();
    });
    $(window).blur(function(){
        $('.slogan').PauseScroller();
    });
});
