/* this class define the category of leaf product */
import Foundation

@objc class Leaf : NSObject
{
    static var leafsTable=[String:Leaf]();

    var category:String
    var name:String
    var months2degrade:Float

    init(value:NSDictionary)
    {
        self.category = ""
        if let category = value["barcode"] as? String {
            self.category = category
        }
        self.name = ""
        if  let name = value["name"] as? String {
            self.name = name;
        }
        self.months2degrade = 10.0
        if let months2degrade = value["months2degrade"]  as? NSString {
            self.months2degrade = months2degrade.floatValue;
        }
        print("Leaf.init \(self.category) : \(self.name) : \(self.months2degrade)");
    }
    class func find(category:String) -> Leaf?
    {
        if let item = leafsTable[category] {
            NSLog("found \(item.category) \(item.months2degrade)")
            return item
        }
        return nil;
    }

    
    class func loadFiles()
    {
        //if let path = NSBundle.mainBundle().pathForResource("assets/Leaves", ofType: "json") {
        if let path = NSBundle.mainBundle().pathForResource("Leaves", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                print("load from \(path)");
                if let jsonObj:NSArray = try NSJSONSerialization.JSONObjectWithData(data, options:  .AllowFragments) as? NSArray  {
                    for item:NSDictionary in jsonObj as! [NSDictionary] {
                        //print("jsonData:\(item)")
                        let leaf = Leaf.init(value:item);
                        leafsTable[leaf.category] = leaf;
                        
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


    
