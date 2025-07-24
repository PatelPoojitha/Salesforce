({

	displayItems : function(component, event, helper) {
		var items = component.get("v.items");
    	var displayItems = [];
    	items.forEach(function (item) {
    		item.selected = false;
            if(item.productCode != null && component.get("v.category") == 'Honda' && (item.productCode).startsWith("Honda")){
                displayItems.push(item);
            }else if (item.productCategory == component.get("v.category")) {
    			displayItems.push(item);
    		}
            //console.log(item.productCode);
    	});
    	component.set("v.displayItems", displayItems);
	},

	getDataHelper : function(component, event, helper) {
		this.showSpinner(component, event, helper);
        var action = component.get("c.getProducts");
        var theId = component.get("v.recordId");
        //Set the Object parameters
        action.setParams({
            opportunityId : theId,
        }); 
        action.setCallback(this, function(response) {
        	this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                var sortedProds = [];
                var partSortedProds = {};
                
                var prods = response.getReturnValue().products;
                prods.forEach(function(prod){
                    var aux = [];
                    var key = prod.productId;
                    if(prod.isChildProduct){
                        key = prod.parentId;
                    }
                    if(partSortedProds[key] != null){
                        aux = partSortedProds[key];
                    }
                    if(prod.isChildProduct){
                        aux.push(prod);
                    }
                    else{
                        aux = [prod].concat(aux);
                    }
                    partSortedProds[key] = aux;
                });
                console.log(partSortedProds);
            	component.set("v.pageTitle", response.getReturnValue().pageTitle);
            	component.set("v.hasError", response.getReturnValue().hasError);
            	if (component.get("v.hasError")) {
            		return;
            	}
            	component.set("v.opportunityId", response.getReturnValue().opportunityId);
            	component.set("v.items", response.getReturnValue().productItems);
            	component.set("v.displayItems", response.getReturnValue().productItems);
            	component.set("v.products", response.getReturnValue().products);
            	component.set("v.serviceItems", response.getReturnValue().serviceItems);
            	component.set("v.isClosed", response.getReturnValue().isClosed);
            	component.set("v.confirm", false);
            	component.set("v.change", false);
            	component.set("v.showCancel", false);
            	component.set("v.categories", response.getReturnValue().categories);
            	component.set("v.category", '--None--');
            	this.displayItems(component, event, helper);
            	var products = component.get("v.products");
                console.log('products', products);
            	var serviceProducts = component.get("v.serviceItems");
            	var items = component.get("v.items");
            	var finalProds = [];
            	var deletedIds = component.get("v.deletedIds");
            	var itemByProductId = new Map();
            	items.forEach(function (item) {
            		itemByProductId.set(item.productId, item);
            	});
            	var serviceItemByProductId = new Map();
            	serviceProducts.forEach(function (item) {
            		serviceItemByProductId.set(item.productId, item);
            	});
            	products.forEach(function (product) {
        			if (itemByProductId.get(product.productId) && !product.isService) {
        				itemByProductId.get(product.productId).alreadySelected = true;
        			}
        			if (serviceItemByProductId.get(product.productId) && product.isService) {
        				serviceItemByProductId.get(product.productId).alreadySelected = true;
        			}
            	});
            	serviceProducts.sort(function(a, b){return a.sortOrder - b.sortOrder});
            	//products.sort(function(a, b){return a.sortOrder - b.sortOrder});
            	items.sort(function(a, b){return a.sortOrder - b.sortOrder});
            	component.set("v.serviceItems", serviceProducts);
            	component.set("v.products", products);
            	component.set("v.items", items);
            	//this.selectDeleteHelper(component, event, helper);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin.');
            }
        });
        $A.enqueueAction(action);
    },
	
	hideSpinner : function(component, event, helper) {
    	component.set("v.spinner", false);
    },
    
    saveData : function(component, event, helper) {
		this.showSpinner(component, event, helper);
		component.set("v.change", false);
		component.set("v.confirm", false);
        var action = component.get("c.saveProducts");
        var theProducts = component.get("v.products");
        var theId = component.get("v.recordId"); 
        var deletedIds = component.get("v.deletedIds");
        //Set the Object parameters
        console.log('theProducts', theProducts);
        action.setParams({
            products : JSON.stringify(theProducts),
            opportunityId : theId,
            delIds : deletedIds
        }); 
        action.setCallback(this, function(response) {
        	this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state === 'SUCCESS') {
            	component.set("v.pageMessage", response.getReturnValue().message);
                this.getDataHelper(component, event, helper);
            	$A.get('e.force:refreshView').fire();
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin.');
            }
        });
        $A.enqueueAction(action);
    },
    
    selectDeleteHelper : function(component, event, helper) {
        /*var products = component.get("v.products");
    	var items = component.get("v.items");   
        var flag = component.get("v.items"); 
    	var prelimProds = [];
    	var finalProds = [];
        var deletedIds = []; 
    	//var deletedIds = component.get("v.deletedIds");
        products.forEach(function(product){
            if(product.deleted){
                deletedIds.push(product.productId);
            }
        });
        console.log(deletedIds);
        products.forEach(function(product){
            if(!deletedIds.includes(product.productId) && !deletedIds.includes(product.parentId)){
                finalProds.push(product.productId);
            }
        });*/
        
        
    	var products = component.get("v.products");
    	var items = component.get("v.items");   
        var flag = component.get("v.items");
        var displayItems = component.get("v.displayItems");
        var serviceItems = component.get("v.serviceItems");        
    	var prelimProds = [];
    	var finalProds = [];
    	var deletedIds = component.get("v.deletedIds");
        console.log('Pablo V Delete>>> ' + deletedIds );
    	var itemByProductId = new Map();
    	items.forEach(function (item) {
            console.log('Pablo V1>>> ' + item );
    		itemByProductId.set(item.productId, item);
    		if (item.selected == true && item.alreadySelected == false) {
    			item.alreadySelected = true;
    			if (item.parentId == null) {
    				prelimProds.push(item);
    			}
    		}
    	});
    	var serviceItemByProductId = new Map();
    	var serviceProducts = component.get("v.serviceItems");
    	serviceProducts.forEach(function (item) {
    		serviceItemByProductId.set(item.productId, item);
    		if (item.selected == true && item.alreadySelected == false) {
    			item.alreadySelected = true;
    			if (item.parentId == null) {
    				prelimProds.push(item);
    			}
    		} 
    	});
    	
    	component.set("v.products", products);
        var delIds = [];
    	products.forEach(function (product) {
    		if (product.deleted) {
                delIds.push(product.productId);
    		}
    	});
        products.forEach(function (prod) {
            if (delIds.includes(prod.parentId)) {
                prod.deleted = true;
            }
        });
    	
    	products.forEach(function (product) {
    		if (product.deleted == false) {
    			if (product.parentId == null) {
    				prelimProds.push(product);
    			}
    		} else { 
    			if (itemByProductId.get(product.productId) && product.isService == false) {
    				itemByProductId.get(product.productId).selected = false;
    				itemByProductId.get(product.productId).alreadySelected = false;
                     console.log('Prueba ' +  itemByProductId.get(product.productId).description);
				}
				if (serviceItemByProductId.get(product.productId) && product.isService == true) {
    				serviceItemByProductId.get(product.productId).selected = false;
    				serviceItemByProductId.get(product.productId).alreadySelected = false;
                    console.log('Prueba ' +  serviceItemByProductId.get(product.productId).description);
				}
				//product.deleted = false;
    			if (product.lineItemId != null) {
                    console.log('Delete ifelse ' + product.productId +' <><><> '+ product.description);    				
                    deletedIds = deletedIds == null ? deletedIds = product.lineItemId + ',' : deletedIds += product.lineItemId + ',';    			                    
                    if (product.associatedFee != null && product.associatedFee.lineItemId != null) {      
                        console.log('associatedFee ');
    					deletedIds += product.associatedFee.lineItemId + ',';
    				}
    				if (product.associatedFee1 != null && product.associatedFee1.lineItemId != null) {
                        console.log('deletedIds associatedFee');
    					deletedIds += product.associatedFee1.lineItemId + ',';
    				}
    				if (product.relatedProduct != null && product.relatedProduct.lineItemId != null) {
    					deletedIds += product.relatedProduct.lineItemId + ',';
    				}                     
    			}
                console.log('OutSide if ' + deletedIds);
    		}
    	});
    	//prelimProds.sort(function(a, b){return a.sortOrder - b.sortOrder});
        console.log('delIds',delIds);
        //deletedIds = '';
    	prelimProds.forEach(function (product) {
            if(!delIds.includes(product.productId) && !delIds.includes(product.parentId)){
                finalProds.push(product);   
            
    		         
            /*Removed the rendered*/
            console.log('Final >>> ' + product.description +'<><<'+ product.displayChilds  +'<><><>'+ product.isChildProduct );
			console.log('Final  2222 >>> ' + product.description +'<><<'+ product.isSelectedRecord  +'<><><>'+ product.isChildProduct );                                     
            
            if(!product.displayChilds && product.isChildProduct && !product.isSelectedRecord){
                console.log('inside REnder Pablo >>> ' + product.isChildProduct  +'<><><>'+ product.deleted +'<><<'+product.description);                         
                //product.displayChilds=true;
            }			
            if (product.associatedFee1 != null) {
                 console.log('Aca en delete %%%' );
				product.associatedFee1.parentId = product.productId;
				product.associatedFee1.minutes = product.minutes;
				finalProds.push(product.associatedFee1);
			}             
			if (product.associatedFee2 != null) {
				product.associatedFee2.parentId = product.productId;
				product.associatedFee2.minutes = product.minutes;
				finalProds.push(product.associatedFee2);
			} 
			if (product.associatedFee3 != null) {
				product.associatedFee3.parentId = product.productId;
				product.associatedFee3.minutes = product.minutes;
				finalProds.push(product.associatedFee3);
			}  
			if (product.associatedFee4 != null) {
				product.associatedFee4.parentId = product.productId;
				product.associatedFee4.minutes = product.minutes;
				finalProds.push(product.associatedFee4);
			}            
			if (product.associatedFee5 != null) {
				product.associatedFee5.parentId = product.productId;
				product.associatedFee5.minutes = product.minutes;
				finalProds.push(product.associatedFee5);
			}  
            if (product.associatedFee6 != null) {
				product.associatedFee6.parentId = product.productId;
				product.associatedFee6.minutes = product.minutes;
				finalProds.push(product.associatedFee6);
			}
            if (product.associatedFee7 != null) {
				product.associatedFee7.parentId = product.productId;
				product.associatedFee7.minutes = product.minutes;
				finalProds.push(product.associatedFee7);
			}            
            if (product.associatedFee8 != null) {
				product.associatedFee8.parentId = product.productId;
				product.associatedFee8.minutes = product.minutes;
				finalProds.push(product.associatedFee8);
			}             
            if (product.associatedFee9 != null) {
				product.associatedFee9.parentId = product.productId;
				product.associatedFee9.minutes = product.minutes;
				finalProds.push(product.associatedFee9);
			}            
            if (product.associatedFee10 != null) {
				product.associatedFee10.parentId = product.productId;
				product.associatedFee10.minutes = product.minutes;
				finalProds.push(product.associatedFee10);
			} 
            }
            /*else{
                console.log('delete', product.lineItemId);
                deletedIds += '' + product.lineItemId + ',';
            }*/
         
    	});
        console.log(finalProds);
        console.log('deletedIds', deletedIds);
    	component.set("v.deletedIds", deletedIds);
    	component.set("v.items", items);
    	component.set("v.serviceItems", serviceProducts);
    	component.set("v.products", finalProds);
    	component.set("v.confirm", false);
    	component.set("v.showCancel", false);
        this.saveData(component, event, helper);
    },
	
	showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
	
})