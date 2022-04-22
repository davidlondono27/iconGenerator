//
//  Home.swift
//  IconGenerator (iOS)
//
//  Created by David Londoño on 21/04/22.
//

import SwiftUI

struct Home: View {
    @StateObject var iconModel: IconViewModel = IconViewModel()
    
    //MARK: Environment Values for theme dark or light mode
    @Environment(\.self) var env
    
    var body: some View {
        VStack(spacing: 15){
            if let image = iconModel.pickedImage{
                
                //MARK: Show image with action
                Group{
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250)
                        .clipped()
                        .onTapGesture(perform: iconModel.PickImage)
                    //MARK: Show generate icon button
                    Button{
                        iconModel.generateIconSet()
                    } label: {
                        Text("Generar Set de iconos")
                            .foregroundColor(env.colorScheme == .dark ? .black : .white)
                            .padding(.vertical,8)
                            .padding(.horizontal,18)
                            .background(.primary,in: RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top,10)
                }
            }else{
                
                //MARK: Add Button
                ZStack{
                    Text("Selecciona una imagen para crear tu icono")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top,10)
                        .frame(maxHeight: .infinity, alignment: .top)
                    Button{
                        iconModel.PickImage()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(env.colorScheme == .dark ? .black : .white)
                            .padding(15)
                            .background(.primary,in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    //Footer text
                    Text("Tamaño recomendado de 1024 X 1024")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom,10)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .frame(width: 400, height: 400)
        .buttonStyle(.plain)
        //MARK: Alert modal
        .alert(iconModel.alertMsg, isPresented: $iconModel.showAlert){
            
        }
        //MARK: Loading View
        .overlay{
            ZStack{
                if iconModel.isGenerating{
                    Color.black
                        .opacity(0.25)
                    
                    ProgressView()
                        .padding()
                        .background(.white,in: RoundedRectangle(cornerRadius: 10))
                    //Activate Light Mode
                        .environment(\.colorScheme, .light)
                }
            }
        }
        .animation(.easeInOut, value: iconModel.isGenerating)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
