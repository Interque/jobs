// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('ready page:load', function(){

	var post_id = $("div.job-posting").attr("data-pk");
	$.fn.editable.defaults.mode = 'inline';
	$.fn.editable.defaults.ajaxOptions = {type: "PUT"};
 	// $("div.job-posting").on("click", function(e){
 	// 	e.preventDefault();
  //  })
		//$(this).closest(".job-posting").attr("data-id");

	$(".listing-title").each(function(){

		var post_id = $(this).attr("data-pk");

		$(this).editable({
			type: 'text',
			url: 'listings/' + post_id,
			success: function(){
				console.log(arguments);
			},
			params: function(params) {
				params.listing = {
					title: params.value
				};
				return params;
			},
			ajaxOptions: {
	       dataType: 'json',
	       type: 'PUT'
	    },
		});
	});


	$(".listing-organization").each(function(){

		var post_id = $(this).attr("data-pk");

		$(this).editable({
			type: 'text',
			url: 'listings/' + post_id,
			success: function(){
				console.log(arguments);
			},
			params: function(params) {
				params.listing = {
					organization: params.value
				};
				return params;
			},
			ajaxOptions: {
	       dataType: 'json',
	       type: 'PUT'
	    },
	  });
	});

	$(".listing-description").each(function(){
		var post_id = $(this).attr("data-pk");
		$(this).editable({
			type: 'textarea',
			url: 'listings/' + post_id,
			success: function(){
				console.log(arguments);
			},
			params: function(params) {
				params.listing = {
					description: params.value
				};
				return params;
			},
			ajaxOptions: {
	       dataType: 'json',
	       type: 'PUT'
	    },
		});
	});

	// $(".listing-email").each(function(){
	// 	var post_id = $(this).attr("data-pk");
	// 	$(this).editable({
	// 		type: 'textarea',
	// 		url: 'listings/' + post_id,
	// 		success: function(){
	// 			console.log(arguments);
	// 		},
	// 		params: function(params) {
	// 			params.listing = {
	// 				email: params.value
	// 			};
	// 			return params;
	// 		},
	// 		ajaxOptions: {
	//        dataType: 'json',
	//        type: 'PUT'
	//     },
	// 	});
	// });

	$(".job-posting").each(function(){
		$(this).find(".edit-button").on("click", function(e){
			// e.preventDefault();
				$(this).closest(".job-posting").find('.editable').addClass('editable-underline');
		});

      $(".editable").on("click", function(){
      	$('.edit-alert').remove();
      		$('.editable').removeClass('editable-underline');
    });
	});

	$(".hide-stuff").hide();

	$('tr').hover(function(){
		$(this).addClass("change-background");
	}, function(){
		$(this).removeClass("change-background");
	});

	$(function(){
		$("#us_states").select2({
			placeholder: "Select a State"
		});
		console.log("tester");
	});

	// $.fn.modal.Constructor.prototype.enforceFocus = function () {
  //     var that = this;
  //     $(document).on('focusin.modal', function (e) {
  //        if ($(e.target).hasClass('select2-input')) {
  //           return true;
  //        }
	//
  //        if (that.$element[0] !== e.target && !that.$element.has(e.target).length) {
  //           that.$element.focus();
  //        }
  //     });
  //  };
});
