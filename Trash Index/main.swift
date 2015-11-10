// test file, compile with
// swiftc Leaf.swift Product.swift main.swift
Leaf.loadFiles();
Product.loadFiles();
if let product = Product.find("012546001250") {
    print("trashIndex for 012546001250 is \(product.trashIndex())");
}
   

