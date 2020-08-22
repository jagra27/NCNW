//
//  ContentView.swift
//  NCNW
//
//  Created by Jada Grant on 8/22/20.
//  Copyright © 2020 Jada Grant. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
     @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View{
        
        VStack{
            
            if self.status{
                Homescreen()
            }
            else{
                Login()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("status"), object: nil, queue: .main) { (_) in
                
                self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
            }
        }
    }
}

struct Homescreen : View {
    
    var body: some View{
        
        VStack{
            
            Text("Logged in successfully")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.black.opacity(0.7))
            
                Button(action: {
                    
                    try! Auth.auth().signOut()
                    UserDefaults.standard.set(false, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                    
                }) {
                    
                    Text("Log out")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 50)
                }
            .background(Color("Color"))
            .cornerRadius(10)
            .padding(.top, 25)
        }
    }
}

struct Login: View {
    
    @State var color = Color.black.opacity(0.7)
    @State var email = ""
    @State var pass = ""
    @State var visible = false
    @State var alert = false
    @State var error = ""
    
    var body: some View{
        
        ZStack{
                VStack{
                    
                    Image("ncnwlogo")
                        .resizable()
                        .frame(width: 380, height: 140)
                    
                    Text("Log in to your account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(self.color)
                    
                    TextField("Email", text: self.$email)
                        .autocapitalization(.none)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color("Color") : self.color, lineWidth: 2))
                        .padding(.top, 25)
                        .frame(width: 300, height: nil)
                
                    HStack(spacing: 15){
                    
                    VStack{
                        
                        if self.visible{
                            
                            TextField("Password", text: self.$pass)
                                .autocapitalization(.none)
                        }
                        else{
                            
                            SecureField("Password", text: self.$pass)
                                .autocapitalization(.none)
                        }
                    }
                        
                    Button(action: {
                        
                        self.visible.toggle()
                        
                    }) {
                        Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(self.color)
                    }
                }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color("Color") : self.color, lineWidth: 2))
                    .padding(.top, 25)
                    .frame(width: 300, height: nil)
            
                
                HStack{
                    
                    Spacer()
                    
                    Button(action: {
                        
                        self.reset()
                        
                    }) {
                        Text("Forgot Password")
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color"))
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.top, 20)
                    
                    Button(action: {
                        
                        self.verify()
                        
                    }) {
                        
                        Text("Log in")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width - 50)
                    }
                .background(Color("Color"))
                .cornerRadius(10)
                .padding(.top, 25)
            }
                .padding(.horizontal,25)
            
            if self.alert{
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    
    func verify(){
        
        if self.email != "" && self.pass != ""{
            
            Auth.auth().signIn(withEmail: self.email, password: self.pass) { (res, err) in
                
                if err != nil{
                    
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                
                print("success")
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }
        }
        else{
            self.error = "Please fill in all the fields"
            self.alert.toggle()
        }
    }
    
    func reset(){
        
        if self.email != ""{
            
            Auth.auth().sendPasswordReset(withEmail: self.email) { (err) in
                
                if err != nil{
                    
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                
                self.error = "RESET"
                self.alert.toggle()
            }
        }
        else{
            
            self.error = "This email doesn't exist for an account. Contact Pres Jada at jagra27@morgan.edu"
            self.alert.toggle()
        }
    }
}

struct ErrorView : View{
    
    @State var color = Color.black.opacity(0.7)
    @Binding var alert : Bool
    @Binding var error : String
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                HStack{
                    
                    Text(self.error == "RESET" ? "Message" : "Error")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(self.color)
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 25)
                
                Text(self.error == "RESET" ? "Password reset link has been sent" : self.error )
                    .foregroundColor(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    
                    self.alert.toggle()
                    
                }) {
                    Text(self.error == "RESET" ? "Ok" : "Cancel")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 120)
                }
                .background(Color("Color"))
                .cornerRadius(10)
                .padding(.top, 25)
            }
            .padding(.vertical, 25)
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(15)
        }
        .background(Color.black.opacity(0.35).edgesIgnoringSafeArea(.all))
    }
}
