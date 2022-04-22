//
//  IconViewModel.swift
//  IconGenerator (iOS)
//
//  Created by David Londoño on 21/04/22.
//

import SwiftUI

class IconViewModel: ObservableObject {
    
    //MARK: Select Image for IconButton
    @Published var pickedImage : NSImage?
    
    //MARK: Alert and load
    @Published var isGenerating: Bool = false
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    
    //MARK: Icon set image sizes
    /*@Published var iconSizes:[Int] = [
        
        20,60,58,87,80,120,180,40,29,76,152
        ,167,1024,16,32,64,128,256,512,1024
    ]*/
    @Published var iconSizes:[Int] = [
        
        16,20,29,32,40,48,50,55,57,58,60,64,
        72,76,80,87,88,100,114,120,128,144,
        152,167,172,180,196,216,256,512,1024
    ]
    
    //MARK: Pick image with NSOpen Panel
    func PickImage(){
        let panel = NSOpenPanel()
        panel.title = "Selecciona una imagen:"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image, .png, .jpeg]
        if panel.runModal() == .OK{
            if let result = panel.url?.path{
                let image = NSImage(contentsOf: URL(fileURLWithPath: result))
                self.pickedImage = image
            }else{
                //MARK: Error
            }
        }
    }
    
    func generateIconSet(){
        
        //MARK: Step by step
        //1. Select destination for icon
        folderSelector{ folderURL in
            //2. Create AppIcon.appiconset folder in this
            let modifiedURL = folderURL.appendingPathComponent("AppIcon.appiconset")
            self.isGenerating = true
            //Running in thread
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    let manager = FileManager.default
                    try manager.createDirectory(at: modifiedURL, withIntermediateDirectories: true, attributes: [:])
                    //3. Writing Contents.json file inside the AppIcon folder
                    self.writeContentsFile(folderURL: modifiedURL.appendingPathComponent("Contents.json"))
                    //4. Create the icons and save inside
                    if let pickedImage = self.pickedImage {
                        self.iconSizes.forEach{ size in
                            let imageSize = CGSize(width: CGFloat(size), height: CGFloat(size))
                            //Set the name for every size
                            let imageURL = modifiedURL.appendingPathComponent("\(size).png")
                            pickedImage.resizeImage(size: imageSize)
                                .writeImage(to: imageURL)
                        }
                        DispatchQueue.main.async {
                            self.isGenerating = false
                            //Save succesfully alert
                            self.alertMsg = "Icono creado exitosamente!"
                            self.showAlert.toggle()
                        }
                    }
                }catch{
                    //MARK: Enter here if error
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.isGenerating = false
                    }
                }
            }
        }
    }
    
    //MARK: Write Contents.json
    func writeContentsFile(folderURL: URL){
        do{
            let bundle = Bundle.main.path(forResource: "Contents", ofType: "json") ?? ""
            let url = URL(fileURLWithPath: bundle)
            try Data(contentsOf: url).write(to: folderURL, options: .atomic)
        }catch{
            //MARK: Enter here if error
        }
    }
    
    //MARK: Select folder using NSOpenPanel
    func folderSelector(completion: @escaping (URL)->()){
        let panel = NSOpenPanel()
        panel.title = "Selecciona un destino:"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [.folder]
        
        if panel.runModal() == .OK{
            if let result = panel.url?.path{
                completion(URL(fileURLWithPath: result))
            }else{
                //MARK: Error
            }
        }
    }
}

//MARK: Extension NSImage to resize the image with new Size
extension NSImage{
    func resizeImage(size: CGSize)->NSImage{
        //Reduce factor for scaling
        //let scale = NSScreen.main?.backingScaleFactor ?? 1
        let scale = 2.0
        let newSize = CGSize(width: size.width / scale, height: size.height / scale)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        //Draw Image
        self.draw(in: NSRect(origin: .zero, size: newSize))
        newImage.unlockFocus()
        return newImage
    }
    //MARK: Writing resized image as PNG
    func writeImage(to: URL){
        //Converting as PNG
        guard let data = tiffRepresentation,let representation = NSBitmapImageRep(data: data), let pngData = representation.representation(using: .png, properties: [:])
        else{
            return
        }
        try? pngData.write(to: to, options: .atomic)
    }
}
