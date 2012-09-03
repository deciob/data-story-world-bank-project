 $(document).ready(function(){
    
    $('#blowup').attr('title','Full Screen');
    //visualization-name click trigger fullscreen visualization
    $('#blowup').live('click', function(e){
         $(this).closest('#visualization-widget').toggleClass('initial');
         $('#app').toggleClass('fullscreen');
         $('#app').removeClass('config-view').removeClass('page-view');
         $('#visualization-config-widget').hide();
         e.preventDefault();    
         
         //swap tipsy text
         if($(this).closest('#app').hasClass('fullscreen')) {
            $(this).attr('title', 'Exit');         
         }else{
            $(this).attr('title', 'Full Screen');
         }               
    
    });       
    
   //Config 
     $('#configbtn').live('click', function(e){
         e.preventDefault();
         $('#app').removeClass('fullscreen').removeClass('page-view');
         $('#app').toggleClass('config-view');  
         $('#visualization-config-widget').toggle();       
    });
    
    //Click the close button will quit the conig-view
    $('.config-view  #close-config, .config-view #close-snapshot').live('click', function(e){
         e.preventDefault();        
         $('#configbtn').click();
    });
     
     //Tipsy plugin - http://onehackoranother.com/projects/jquery/tipsy/
     $('a.live-tipsy').tipsy({trigger: 'hover', live: true, gravity: $.fn.tipsy.autoNS}); 
     $('#configbtn, #blowup, #close-config, #close-snapshot, #project-login-link,#local-projects-title, #account-projects-title').tipsy({live: true, gravity: 'e'}); 
     $('#visualization-name .name, #logout-link, #login-link').tipsy({live: true, gravity: 'n'});    
     
    //jQuery Scrollpane
   $('#indicator-list-section').jScrollPane();
     
   // Enter snapshot view (page-view)
   $('#pages li.item').live('click', function(){
       $('#app').removeClass('fullscreen').removeClass('config-view');
       $('#app').addClass('page-view');        
    
   });
    
    // Exit snapshot view (page-view)
    $('#all-projects li.item, #new-local-project, #new-local-project').live('click', function(){       
       $('#app').removeClass('page-view');     
    });    
   
   //Projects list custom show/hide
   $('#all-projects h2').click(function(){
       var ico = $(this).find('span').toggleClass('open');
       $(this).closest('div').find('.project-dropdown').slideToggle(ico.hasClass("open"));
   });
   
   //Click the project title will hide the projects list
   /*
   $('#all-projects').delegate('li.item', 'click', function(e){
       $("#all-projects .project-dropdown").slideUp();
       $("#all-projects h2 span").removeClass('open');
   });*/
   
   $('.page-view #close-snapshot').live('click', function(){
       $('#all-projects').show();
       $('#app').removeClass('page-view').removeClass('config-view').removeClass('fullscreen');
       //hide snapshot nav
       $('#snapshot-nav').hide();
   });
   
   //Page-view: snapshot nav   
   $('.page-view #visualization-widget').live({
        mouseenter:
           function()
           {    
               
                $(this).find('#snapshot-nav').show();
               
           },
        mouseleave:
           function()
           {
               $(this).find('#snapshot-nav').hide();
           }
    });
    
 });
 
 

 
    
 
 
 

























