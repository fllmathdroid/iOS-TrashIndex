import Foundation

@objc class Product : NSObject
{
    static var productsTable=[String:Product]()
    var barcode=String()
    var name=String()
    var leafs=[String]()
    var leafFractions = [Float]();

    init(value:NSDictionary)
    {
        if let barcode = value["barcode"] as? String {
            self.barcode = barcode
        }
        if let name = value["name"] as? String {
            self.name = name
        }
        if  let leafs = value["leafs"] as? [String] {
            self.leafs = leafs;
        }

        if let leafFractions:[NSString] = value["leafFractions"]  as? [NSString] {
            for fraction:NSString in leafFractions {
                self.leafFractions.append(fraction.floatValue);
            }
        }
        print("Product.init \(self.barcode) : \(self.name) : \(self.leafs) : \(self.leafFractions)");
    }

    // function to calculate trashIndex
    func trashIndex() -> UInt
    {
        var returnVal:Float = 0.0; // init value
        for var index = 0; index < self.leafs.count; index++ {
            let category = self.leafs[index];
            if index < self.leafFractions.count  {
                let fract:Float = self.leafFractions[index];
                if let leaf:Leaf = Leaf.find(category) {
                    print("found leaf for \(leaf.name) months2degrade \(leaf.months2degrade)");
                    returnVal += sqrt(leaf.months2degrade)*5 * fract
                } else {
                    print("cound not find leaf for \(category)")
                }
            } else {
                print("mismatch leafs and leafFractions")
            }
        }
        if returnVal > 1000.0 {
           returnVal = 1000.0;
        }

        let retInt:UInt = UInt( returnVal);
        print("trashIndex for \(self.barcode) is \(retInt)");
        return retInt;
    }
               
    class func find(barcode:String) -> Product?
    {
        if let item = productsTable[barcode] {
            NSLog("found \(item.barcode) \(item.leafs)")
            return item
        }
        return nil;
    }

    
    class func loadFiles()
    {
        //if let path = NSBundle.mainBundle().pathForResource("assets/Composites", ofType: "json") {
        if let path = NSBundle.mainBundle().pathForResource("Composites", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                print("load from \(path)");
                if let jsonObj:NSArray = try NSJSONSerialization.JSONObjectWithData(data, options:  .AllowFragments) as? NSArray  {
                    for item:NSDictionary in jsonObj as! [NSDictionary] {
                        //print("jsonData:\(item)")
                        let product = Product.init(value:item);
                        productsTable[product.barcode] = product;
                        
                    }
                } else {
                    print("could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
        print("Invalid filename/path.")
        }

    }
    
}
