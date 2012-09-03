 $(document).ready(function(){
 
   
   //jQuery tabs
   $('#demos-container').tabs();  
  
    //Site page ui dialog
    $('a[rel=site-page]').live('click',function(e){
        e.preventDefault(); 
        //Whenever opening a dialog, make sure all others are closed
        $(".ui-dialog-content").dialog("close");        
        var pageToLoad = $(this).attr('href');
        var pageTitle = $(this).text();
        $('#site-page-window')
        .dialog({ width: 800, height: 600, title: pageTitle,  resizable: false})
        .load(pageToLoad);    
    
    });
    
    //Landing page video dialog
    $('#demo-video').live('click',function(e){
        e.preventDefault(); 
        //Whenever opening a dialog, make sure all others are closed
        $(".ui-dialog-content").dialog("close");        
        $('#video-window')
        .dialog({ width: 760, height: 560, title: 'Demo Video',  resizable: false}); 
        $('#video-tabs').tabs({ selected: 0 });    
    });  
    
    //Click the ui dialog close button will stop the youtube video
    $('.ui-dialog-titlebar-close').live('click', function(e){         
         e.preventDefault(); 
        //stop youtube video              
        $('#video-window').find('embed').stopVideo();
    });
    
    
    //Tipsy
    $('#login-link').tipsy({live: true, gravity: 's'}); 
    
    $('#vote-label').tipsy({live: true, gravity: 'w'}); 
   
 });
 
 























