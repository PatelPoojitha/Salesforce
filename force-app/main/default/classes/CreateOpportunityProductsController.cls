/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Controller for the CreateOpportunityProducts Component
       Test code in CreateOpportunityProductsTest class.
*/

public class CreateOpportunityProductsController {
    
    /* Constructor */
    
    public CreateOpportunityProductsController() {
    }
    
    /* Static Methods */
    
    @AuraEnabled
    public static ProductData getProducts(String opportunityId) {
        Opportunity opp = [select Pricebook2Id, Tier_2_Type__c from Opportunity where Id = :opportunityId];
        Id pricebookId = opp.Pricebook2Id;
        List<Product> theProducts = new List<Product>();
        Map<Id, List<Product>> productsByAssociatedId = new Map<Id, List<Product>>();
        Map<Id, List<Product>> productsByRelatedId = new Map<Id, List<Product>>();
        Product product;
        for (PricebookEntry item : [select unitPrice, product2.minutes__c, product2.name, product2Id, product2.product_category__c,
                                    product2.Product_Category_Sort__c, Product2.Associated_Setup_Fee__c, product2.Related_Product_To_Add__c,
                                    product2.Retail_Sales_Volume__c, product2.DNI_Licensed_URL__c, product2.Discounts_Restricted__c, product2.ProductCode,
                                    Product2.Associated_Product_1__c,Product2.Associated_Product_1__r.Name, Product2.Associated_Product_2__c, Product2.Associated_Product_3__c, Product2.Associated_Product_4__c
                                    from PricebookEntry 
                                    where pricebook2Id = :pricebookId AND product2.IsActive = true order by product2.Product_Category_Sort__c]) 
        {
            product = new Product(item.product2.name, item.unitPrice, item.unitPrice, Integer.valueOf(item.product2.minutes__c), item.product2.DNI_Licensed_URL__c,
                                  item.product2Id, item.Id, null, item.product2.product_category__c, item.product2.Product_Category_Sort__c, 1, null, null, false, null,
                                  item.product2.Retail_Sales_Volume__c, item.Product2.Discounts_Restricted__c, item.Product2.productCode);
            if((opp.Tier_2_Type__c == 'ADDP' && (item.product2.name.contains('ADDP') || item.product2.name.contains('Acura Dealer Digital Program'))) || opp.Tier_2_Type__c != 'ADDP'){
                theProducts.add(product);
            }
            
            /*
            if(item.Product2.Associated_Product_1__c != null){
              product = new Product(item.Product2.Associated_Product_1__r.Name, item.unitPrice, item.unitPrice, Integer.valueOf(item.product2.minutes__c), item.product2.DNI_Licensed_URL__c,
                                               item.Product2.Associated_Product_1__c, item.Id, null, item.product2.product_category__c, item.product2.Product_Category_Sort__c, 1, null, null, false, null,
                                               item.product2.Retail_Sales_Volume__c, item.Product2.Discounts_Restricted__c,false,false);
                theProducts.add(product);                                        
            }
			*/
 
        }
        for (PricebookEntry item : [select unitPrice, product2.minutes__c, product2.name, product2Id, product2.product_category__c,
                					product2.Product_Category_Sort__c, product2.Retail_Sales_Volume__c, product2.DNI_Licensed_URL__c, product2.Discounts_Restricted__c from PricebookEntry 
                                    where pricebook2Id = :pricebookId AND product2.IsActive = true
                					and (product2Id in :productsByAssociatedId.keySet() or product2Id in :productsByRelatedId.keySet())
                					order by product2.Product_Category_Sort__c]) {
            	
                product = new Product(item.product2.name, item.unitPrice, item.unitPrice, Integer.valueOf(item.product2.minutes__c), item.product2.DNI_Licensed_URL__c,
                					  item.product2Id, item.Id, null, item.product2.product_category__c, item.product2.Product_Category_Sort__c, 1, null, null, false, null,
               						  item.product2.Retail_Sales_Volume__c, item.Product2.Discounts_Restricted__c,false,false);
            if((opp.Tier_2_Type__c == 'ADDP' && (item.product2.name.contains('ADDP') || item.product2.name.contains('Acura Dealer Digital Program'))) || opp.Tier_2_Type__c != 'ADDP'){
                theProducts.add(product);
            }
        }
        ProductData response = new ProductData(theProducts, opportunityId, pricebookId);
        for(Product element : response.products){
            //sortedList.add(element);
            System.debug(element);
        }
        return response;
    }
    
    @AuraEnabled
    public static DataSave saveProducts(String products, String opportunityId, String delIds) {
        Set<Id> deleteIds = new Set<Id>();
        if (String.isNotBlank(delIds)) {
            delIds.removeEnd(',');
            List<String> splitDelIds = delIds.split(',');
            for (String id : splitDelIds) {
                deleteIds.add(id);
            }
        }
        List<Product> theProducts;
        if (products != null && products.startsWith('[')) {
            theProducts = (List<Product>)JSON.deserialize(products, List<Product>.class);
        } else if (products != null) {
            theProducts = new List<Product> { (Product)JSON.deserialize(products, Product.class) };
        } else {
            return new DataSave();
        }
        List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
        for (Product product : theProducts) {
            lines.add(new OpportunityLineItem(Id = product.lineItemId, opportunityId = opportunityId, product2Id = product.productId, 
                pricebookEntryId = product.pricebookEntryId, unitPrice = product.unitPrice, quantity = product.quantity, 
                Parent_Product_ID__c = product.parentId, minutes__c = product.minutes, DNI_Licensed_URL__c = product.dniLicensedUrl));
            if (deleteIds.contains(product.lineItemId)) {
                deleteIds.remove(product.lineItemId);
            } 
        }
        /*for (OpportunityLineItem line : lines) {
            upsert line;
        }*/
        upsert lines;
        delete [select Id from OpportunityLineItem where Id in :deleteIds];
        return new DataSave();
    }
    
    /* Inner Classes */
    
    public class Product {
        
        @AuraEnabled
        public Boolean alreadySelected { get; set; }
        @AuraEnabled
        public Product associatedFee { get; set; }
        @AuraEnabled
        public Boolean deleted { get; set; }
        @AuraEnabled
        public String description { get; private set; }
        @AuraEnabled
        public Boolean isService { get; set; }
        @AuraEnabled
        public String lineItemId { get; private set; }
        @AuraEnabled
        public Decimal listPrice { get; private set; }
        @AuraEnabled
        public Integer minutes { get; private set; }
        @AuraEnabled
        public String dniLicensedUrl {get; private set;}
        @AuraEnabled
        public String parentId { get; private set; }
        @AuraEnabled
        public String pricebookEntryId { get; private set; }
        @AuraEnabled
        public Decimal pricePerUnit { get; private set; }
        @AuraEnabled
        public String productCategory { get; private set; }
        @AuraEnabled
        public String productId { get; set; }
        @AuraEnabled
        public Integer quantity { get; set; }
        @AuraEnabled
        public Product relatedProduct { get; set; }
        @AuraEnabled
        public Boolean selected { get; set; }
        @AuraEnabled
        public Decimal sortOrder { get; private set; }
        @AuraEnabled
        public Date startDate { get; private set; }
        @AuraEnabled
        public Decimal unitPrice { get; set; }
        @AuraEnabled
        public String volume { get; set; }
        @AuraEnabled
        public Boolean isDiscountRestricted { get; set; }
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public Product associatedFee1 { get; set; }
        @AuraEnabled
        public Product associatedFee2 { get; set; }
        @AuraEnabled
        public Product associatedFee3 { get; set; }  
        @AuraEnabled
        public Product associatedFee4 { get; set; }          
        @AuraEnabled
        public Product associatedFee5 { get; set; }
        @AuraEnabled
        public Product associatedFee6 { get; set; }
        @AuraEnabled
        public Product associatedFee7 { get; set; }
        @AuraEnabled
        public Product associatedFee8 { get; set; }
        @AuraEnabled
        public Product associatedFee9 { get; set; }
        @AuraEnabled
        public Product associatedFee10 { get; set; }        
        /**/
        @AuraEnabled
        public Boolean isChildProduct{get;set;}
        @AuraEnabled
        public Boolean displayChilds{get;set;}
        @AuraEnabled
        public Boolean isSelectedRecord{get;set;}		    
        
        public Product(String descript, Decimal unPrice, Decimal lsPrice, Integer min, String dniUrl, Id prod2Id, 
                       Id pbEntryId, Id lineId, String prodCategory, 
                		Decimal srtOrder, Decimal qty, Decimal pricePer, Date effectiveDate, 
                       Boolean serv, String parent, String vol, Boolean isDiscountRestricted,
                       Boolean isChildProduct,Boolean displayChilds) {
            this.volume = vol;
            this.parentId = parent;
            this.isService = serv;
            this.sortOrder = srtOrder == null ? 100000 : srtOrder;
            this.description = descript;
            this.unitPrice = unPrice;
            this.listPrice = lsPrice;
            this.quantity = Integer.valueOf(qty);
            this.minutes = min;
            this.dniLicensedUrl = dniUrl;
            this.deleted = false;
            this.productId = prod2Id;
            this.pricebookEntryId = pbEntryId;
            this.lineItemId = lineId;
            this.productCategory = prodCategory;
            this.selected = false;
            this.alreadySelected = false;
            this.pricePerUnit = pricePer;
            this.startDate = effectiveDate;
            this.isDiscountRestricted = isDiscountRestricted;
            this.isChildProduct=isChildProduct;
            this.displayChilds=displayChilds;
            //isSelectedRecord=false;
        }
        
        public Product(String descript, Decimal unPrice, Decimal lsPrice, Integer min, String dniUrl, Id prod2Id, Id pbEntryId, Id lineId, String prodCategory, 
                Decimal srtOrder, Decimal qty, Decimal pricePer, Date effectiveDate, Boolean serv, String parent, String vol, Boolean isDiscountRestricted, String productCode) {
            this.volume = vol;
            this.parentId = parent;
            this.isService = serv;
            this.sortOrder = srtOrder == null ? 100000 : srtOrder;
            this.description = descript;
            this.unitPrice = unPrice;
            this.listPrice = lsPrice;
            this.quantity = Integer.valueOf(qty);
            this.minutes = min;
            this.dniLicensedUrl = dniUrl;
            this.deleted = false;
            this.productId = prod2Id;
            this.pricebookEntryId = pbEntryId;
            this.lineItemId = lineId;
            this.productCategory = prodCategory;
            this.selected = false;
            this.alreadySelected = false;
            this.pricePerUnit = pricePer;
            this.startDate = effectiveDate;
            this.isDiscountRestricted = isDiscountRestricted;
            this.productCode = productCode;
        }
    }
    
    
    
    public class ProductData {
        
        @AuraEnabled
        public List<String> categories { get; private set; }
        @AuraEnabled
        public Boolean hasError { get; private set; }
        @AuraEnabled
        public Boolean isClosed { get; private set; }
        @AuraEnabled
        public String opportunityId { get; private set; }
        @AuraEnabled
        public String pageTitle { get; private set; }
        @AuraEnabled
        public List<Product> productItems { get; set; }
        @AuraEnabled
        public List<Product> products { get; set; }
        @AuraEnabled
        public List<Product> serviceItems { get; set; }
       
           
        public ProductData(List<Product> prodItems, String oppId, String pricebookId) {
            system.debug('checking prod ' + prodItems+'\n');
            opportunityId = oppId;
            productItems = prodItems;
            Id pilotRTId = [select Id from RecordType where sObjectType = 'Opportunity' and developerName = 'Trial_Pilot'].Id;
            Opportunity opportunity = [select isClosed, name, Order_Type__c, Service_Agreement__c, recordTypeId, recordType.Name, Tier_2_Type__c from Opportunity where Id = :oppId];
            isClosed = opportunity.isClosed;
            pageTitle = 'Create Products for ' + opportunity.name;
            hasError = false; 
            Product product;
          
            Product productChild;
            Map<Id, List<Product>> productsByAssociatedId = new Map<Id, List<Product>>();
            Map<Id, List<Product>> productsByRelatedId = new Map<Id, List<Product>>();
            List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
            products = new List<Product>();
            Map<String,Product> productMapChild = new Map<String,Product>();
            //Debug
            Integer cont=0;
            Map<String, List<String>> linesByParents = new Map<String, List<String>>();
            Set<String> associatedProductsId = new Set<String>();
            List<OpportunityLineItem> curLines = [select Id,product2.name, unitPrice, product2.minutes__c, product2Id, 
                                             pricebookEntryId,DNI_Licensed_URL__c, pricebookEntry.unitPrice, 
                                             product2.product_category__c, product2.Product_Category_Sort__c,
                                 quantity, Parent_Product_ID__c,  
                                             Product2.Associated_Product_1__c,Product2.Associated_Product_2__c,
                                             Product2.Associated_Product_3__c,Product2.Associated_Product_4__c,
                                             Product2.Associated_Product_5__c,Product2.Associated_Product_6__c,
                                             Product2.Associated_Product_7__c,Product2.Associated_Product_8__c,
                                             Product2.Associated_Product_9__c,Product2.Associated_Product_10__c,                                             
                                             Product2.Associated_Product_1__r.Name,Product2.Associated_Product_2__r.Name,
                                             Product2.Associated_Product_3__r.Name,Product2.Associated_Product_4__r.Name,
                                             Product2.Associated_Product_5__r.Name,Product2.Associated_Product_6__r.Name,
                                             Product2.Associated_Product_7__r.Name,Product2.Associated_Product_8__r.Name,      
                                             Product2.Associated_Product_9__r.Name,Product2.Associated_Product_10__r.Name,                                              
                                             Product2.Associated_Setup_Fee__c, product2.Related_Product_To_Add__c, 
                                             product2.Discounts_Restricted__c
                                 from OpportunityLineItem where opportunityId = :oppId AND product2.IsActive = true 
                                             order by product2.Product_Category_Sort__c];
            for(OpportunityLineItem line: curLines){
              if(line.Parent_Product_ID__c != null){
                List<String> linesByParent = new List<String>();
                if(linesByParents.containsKey(line.Parent_Product_ID__c)){
                  linesByParent = linesByParents.get(line.Parent_Product_ID__c);
                }
                linesByParent.add(line.product2Id);
                linesByParents.put(line.Parent_Product_ID__c,linesByParent);
              }
                else{
                    if(!linesByParents.containsKey(line.product2Id)){
                        linesByParents.put(line.product2Id,new List<String>());
                    }
                    for(Integer i = 1; i <= 10; i++){
                        String field = 'Associated_Product_'+i+'__c';
                        if((String)line.Product2.get(field) != null){
                            associatedProductsId.add((String)line.Product2.get(field));
                        }
                    }
                }
            }
            Map<String, pricebookEntry> entryByProd = new Map<String, pricebookEntry>();
            if(associatedProductsId.size() > 0){
                for(PricebookEntry element : [SELECT Id, Pricebook2Id, UnitPrice, IsActive, Product2Id, Product2.minutes__c, product2.product_category__c,
                                              product2.Product_Category_Sort__c, product2.Discounts_Restricted__c
                                              FROM PricebookEntry 
                                              WHERE Product2Id IN: associatedProductsId AND Pricebook2Id =: pricebookId]){
                    entryByProd.put(element.Product2Id, element);
                }
            }
            
            for (OpportunityLineItem line : curLines) {
                lines.add(line);
                                                 
                if (line.Parent_Product_ID__c == null) {
                    product = new Product(line.product2.name, line.unitPrice, line.pricebookEntry.unitPrice, 
                                          Integer.valueOf(line.product2.minutes__c),line.DNI_Licensed_URL__c, line.product2Id, 
                                          line.pricebookEntryId, line.Id, line.product2.product_category__c,
                        				  line.product2.Product_Category_Sort__c, line.quantity, null, null, false, 
                                          null, null, line.product2.Discounts_Restricted__c,false,false);                
                    products.add(product);
                    List<String> linesByParent = linesByParents.get(line.product2Id);
                    for(Integer i = 1; i <= 10; i++){
                        String field = 'Associated_Product_'+i+'__c';
                        System.debug(field);
                        String ap = (String)line.Product2.get(field);
                        System.debug(ap);
                        if(ap != null && !linesByParent.contains(ap)){
                            System.debug('new');
                          String Name = '';
                          switch on i {
                            when 1 {   
                              Name = line.Product2.Associated_Product_1__r.Name;
                            } 
                            when 2 {   
                              Name = line.Product2.Associated_Product_2__r.Name;
                            }
                            when 3 {   
                              Name = line.Product2.Associated_Product_3__r.Name;
                            }
                            when 4 {   
                              Name = line.Product2.Associated_Product_4__r.Name;
                            }
                            when 5 {   
                              Name = line.Product2.Associated_Product_5__r.Name;
                            }
                            when 6 {   
                              Name = line.Product2.Associated_Product_6__r.Name;
                            }
                            when 7 {  
                              Name = line.Product2.Associated_Product_7__r.Name;
                            }
                            when 8 {    
                              Name = line.Product2.Associated_Product_8__r.Name;
                            }
                            when 9 {     
                              Name = line.Product2.Associated_Product_9__r.Name;
                            }
                            when 10 {     
                              Name = line.Product2.Associated_Product_10__r.Name;
                            }
                          }
                          pricebookEntry pe = entryByProd.get((String)line.Product2.get(field));
                          Product product1 = new Product(Name, 
                                                   pe.unitPrice,
                                                 pe.unitPrice, 
                                                   Integer.valueOf(pe.product2.minutes__c),
                                         line.DNI_Licensed_URL__c, 
                                                   (String)line.Product2.get(field), 
                                                   pe.Id, 
                                                 null, 
                                                   line.product2.product_category__c,
                                         line.product2.Product_Category_Sort__c, 
                                                   line.quantity, 
                                               null, null, false, 
                                                   line.Product2Id, null, 
                                                   pe.product2.Discounts_Restricted__c,true,false);
                          products.add(product1);
                        }
                    }
                    
                }
                else{
                    System.debug('additional');
                  product = new Product(line.product2.name, line.unitPrice, line.pricebookEntry.unitPrice, 
                                          Integer.valueOf(line.product2.minutes__c),line.DNI_Licensed_URL__c, line.product2Id, 
                                          line.pricebookEntryId, line.Id, line.product2.product_category__c,
                                  line.product2.Product_Category_Sort__c, line.quantity, null, null, false, 
                                          line.Parent_Product_ID__c, null, line.product2.Discounts_Restricted__c,true,false); 
                    products.add(product);
                }
            }
            system.debug('Products ' + products.size());
            categories = new List<String>();
            List<Products_component_settings__mdt> productCategories = [SELECT Product_Category__c 
                                                                        FROM Products_component_settings__mdt
                                                                        WHERE Record_Type__c =: opportunity.recordType.Name];

            if(productCategories.isEmpty()) {
                for (String theCategory : buildPickList('Product2', 'Product_Category__c')) {
                    if (opportunity.recordTypeId == pilotRTId && (theCategory == 'OEM & Trials w/Add On' || theCategory == '--None--')) {
                        categories.add(theCategory);
                    } else if (opportunity.recordTypeId != pilotRTId && theCategory != 'OEM & Trials w/Add On') {
                        categories.add(theCategory);
                    }
                }
            } else {
                for (Products_component_settings__mdt prodCat : productCategories) {    
                    if(!String.isBlank(prodCat.Product_Category__c) && (prodCat.Product_Category__c != 'Honda' || opportunity.Tier_2_Type__c == 'HDS' || opportunity.Tier_2_Type__c == 'ADDP')) {
                        categories.add(prodCat.Product_Category__c);
                    }
                }
            }

            serviceItems = new List<Product>();
            Set<Id> productIds = new Set<Id>();
            for (Service_Agreement_Products__c theProduct : [select name, product__r.minutes__c, Quantity__c, Price_Per_Unit__c, Effective_Date__c, 
                    product__c, product__r.product_category__c, product__r.Product_Category_Sort__c, product__r.DNI_Licensed_URL__c, product__r.Discounts_Restricted__c
                    from Service_Agreement_Products__c where CallRevu_Contract__c = :opportunity.Service_Agreement__c and End_Date__c = null AND product__r.IsActive = true]) {
                    
                    serviceItems.add(new Product(theProduct.name, theProduct.price_per_unit__c, null, Integer.valueOf(theProduct.product__r.minutes__c), 
                    theProduct.product__r.DNI_Licensed_URL__c, theProduct.product__c, null, null, theProduct.product__r.product_category__c,
                    theProduct.product__r.Product_Category_Sort__c, theProduct.quantity__c, theProduct.price_per_unit__c, theProduct.Effective_Date__c,
                    true, null, null, theProduct.product__r.Discounts_Restricted__c,false,false));
                        
                productIds.add(theProduct.product__c);
            } 
            Map<Id, PriceBookEntry> entryByProductId = new Map<Id, PriceBookEntry>();
            for (PricebookEntry entry : [select unitPrice, product2Id from PriceBookEntry where pricebook2Id = :pricebookId 
                    and product2Id in :productIds]) {
                entryByProductId.put(entry.product2Id, entry);
            }
            for (Product theProduct : serviceItems) {
                theProduct.pricebookEntryId = entryByProductId.get(theProduct.productId).Id;
                theProduct.listPrice = entryByProductId.get(theProduct.productId).unitPrice;
            }
            sortProducts();
            
            system.debug('Products ' + products.size());
        }
        private void sortProducts(){
            List<Product> sortedList = new List<Product>();
            Map<String, Map<String, List<Product>>> orderProds = new Map<String, Map<String, List<Product>>>();
            for(Product element: products){
                if(!element.isChildProduct){
                    Map<String, List<Product>> prodSorted = new Map<String, List<Product>>();
                    prodSorted.put('parent', new List<Product>{element});
                    prodSorted.put('children', new List<Product>());
                    orderProds.put(element.productId, prodSorted);
                }
            }
            for(Product element: products){
                if(element.isChildProduct){
                    Map<String, List<Product>> prodSorted = orderProds.get(element.parentId);
                    List<Product> children = prodSorted.get('children');
                    children.add(element);
                    prodSorted.put('children', children);
                    orderProds.put(element.parentId, prodSorted);
                }
            }
            for(String key : orderProds.keySet()){
                for(Product element : orderProds.get(key).get('parent')){
                    sortedList.add(element);
                    System.debug(element);
                }
                for(Product element : orderProds.get(key).get('children')){
                    sortedList.add(element);
                    System.debug(element);
                }
                /*System.debug(orderProds.get(key).get('parent').size());
                System.debug(orderProds.get(key).get('children').size());
                sortedList.addAll(orderProds.get(key).get('parent'));
                sortedList.addAll(orderProds.get(key).get('children'));*/
            }
            products = sortedList;
        }
        private List<String> buildPickList(String theObject, String theField) {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
            Schema.SObjectType systemObjectType = gd.get(theObject);  
            Schema.DescribeSObjectResult r = systemObjectType.getDescribe();  
            Schema.SObjectField fieldResult = r.fields.getMap().get(theField); 
            Schema.DescribeFieldResult fieldDescribe = fieldResult.getDescribe();
            List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
            List<String> choices = new List<String> { '--None--' };
            for (Schema.PicklistEntry f : ple) {
                choices.add(f.getLabel());
            }
            return choices;
        }
    }
    
    public class DataSave {
        
        @AuraEnabled
        public String message { get; private set; }
        
        public DataSave() {
            message = null;
        }
    }
}