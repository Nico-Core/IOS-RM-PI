DEBUG = False

import socket
import struct
from threading import Thread
from threading import Timer
from enum import Enum
import time
import sys
if not DEBUG :
    import gpiozero

SIZEOFDATA = 11

class comProtcol(Enum):
    isChanged = "1"
    ok = "2" 
    sendData = "3"
    fail = "4"
    changeState = "5"
    closeCon = "6"
    end = "7"



class ioPi:
    def __init__( self):
        self.__change : bool    = False
        self.__ioData           = []

    def CreateIO( self, name:str, pin:int):
        self.__change = True
        if DEBUG:
            self.__ioData.append([name, pin, False])
        else:
            self.__ioData.append([name, gpiozero.DigitalOutputDevice(pin),False])
        
        
    def DeleteIO( self, name:str):
        self.__change = True
        #delete output pin from the pin list is missing

    def ChangeIO( self, name:str, state:bool):
        for data in self.__ioData: 
            if data[0] == name:
                data[2] = state
                if state :
                    if DEBUG: 
                        print(str(name)+" : "+str(state))
                    else:
                        print(str(name)+" : "+str(state))
                        data[1].on()
                else:
                    if DEBUG:
                        print(str(name)+" : "+str(state))
                    else:
                        print(str(name)+" : "+str(state))
                        data[1].off()
                         
                self.__change = True
                return True
        return False                
          
    def Changed( self):
        return self.__change

    def SizeOfDataList(self):
        return len( self.__ioData )

    def GetData( self):
        self.__change = False
        return self.__ioData

    def TestGetData( self):
        if self.__change:
            for data in self.__ioData:
                print(data[0] + "-" + str(data[1]) + "-" + str(data[2]))
        else:
            print("Not changed!!!") 


#multi client support for changed output pin state is missing
class clientHandler(Thread):
    def __init__(self, threadList, conn, io):
        self.__threadList       = threadList
        self.__connClient       = conn
        self.__ioData           = io

        Thread.__init__(self)

    def IsChanged(self):
        if self.__ioData.Changed():
            self.__connClient.send( comProtcol.ok.value.encode("utf8") )
            self.__connClient.send( str(self.__ioData.SizeOfDataList() ).encode("utf8") )
            
            command = self.__connClient.recv(1).decode("utf8")
            if command == comProtcol.ok.value:
                for data in self.__ioData.GetData():
                    self.__connClient.send( struct.pack(">10s?", data[0].encode("utf8"), data[2]) )
            elif command == comProtcol.fail.value:
                return

        else:
            print("Nothing changed")
            self.__connClient.send(comProtcol.end.value.encode("utf8"))

    def ChangeState(self):
        self.__connClient.send( comProtcol.ok.value.encode("utf8") )
        name, state = struct.unpack(">10s?", self.__connClient.recv(SIZEOFDATA))
        self.__ioData.ChangeIO( str(name, "utf8").split('\x00')[0], state )

    def run(self):
        alive = True
        while alive: #stop by timeout is missing
            try:
                command = self.__connClient.recv(1).decode("utf8")
            except:
                print("Error : " + str(sys.exc_info()))
                break

            if command == comProtcol.isChanged.value:
                self.IsChanged()
            elif command == comProtcol.changeState.value:
                self.ChangeState()
            elif command == comProtcol.closeCon.value:
                alive = False
            else:
                alive = False

        self.__threadList.remove(self)
        self.__connClient.close()
        


class server:
    def __init__(self):
        self.__threadList   = []
        self.ioStream       = ioPi()

        self.__serverSocket = socket.socket( socket.AF_INET, socket.SOCK_STREAM)
        self.__serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
       
        try:
            self.__serverSocket.bind(("", 1000))
        except:
            print("Bind failed. Error : " + str(sys.exc_info()))
            sys.exit()

        self.__serverSocket.listen(10)
        
    def Main(self):
        while True:
            print("Number of clients: "+str(len(self.__threadList)))
            conn, addr = self.__serverSocket.accept()
            clientThread = clientHandler( self.__threadList, conn, self.ioStream)
            self.__threadList.append(clientThread)
            clientThread.start()
        
        for t in self.__threadList:
            t.join()

        self.__serverSocket.close()

                

if __name__ == '__main__':
    Server = server()

    if DEBUG:
        print("Debug mode")
        Server.ioStream.CreateIO( "Licht1", 1)
        Server.ioStream.CreateIO( "Licht2", 1)
        Server.ioStream.CreateIO( "Licht3", 1)
        Server.ioStream.CreateIO( "Licht4", 1)
        Server.ioStream.CreateIO( "Licht5", 1)
    else:
        print("Live mode")
        Server.ioStream.CreateIO( "Licht1", 4)

    Server.Main()
    input("End")