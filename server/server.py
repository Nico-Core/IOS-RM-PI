DEBUG = True

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
    fail = "3"
    changeState = "4"
    closeCon = "5"
    end = "6"



class ioPi:
    def __init__( self):
        self.__ioData = []

    def CreateIO( self, name:str, pin:int):
        if len(name) > 10:
            return False

        if DEBUG:
            self.__ioData.append([name, pin, False])
        else:
            self.__ioData.append([name, gpiozero.DigitalOutputDevice(pin),False])

        return True
        
        
    def DeleteIO( self, name:str):
        pass
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
                return True
        return False                

    def SizeOfDataList(self):
        return len( self.__ioData )

    def GetData( self):
        return self.__ioData

    if DEBUG:
        def TestGetData( self):
            for data in self.__ioData:
                print(data[0] + "-" + str(data[1]) + "-" + str(data[2]))


#multi client support for changed output pin state is missing
class clientHandler(Thread):
    def __init__(self, threadList, conn, io):
        self.__changed : bool   = True
        self.__threadList       = threadList
        self.__connClient       = conn
        self.__ioData           = io

        Thread.__init__(self)


    def IsChanged(self):
        if self.__changed:
            if DEBUG:
                print("Function IsChanged")

            self.__connClient.send( comProtcol.ok.value.encode("utf8") )
            if DEBUG:
                print("Send command: ok")

            self.__connClient.send( str(self.__ioData.SizeOfDataList() ).encode("utf8") )
            if DEBUG:
                print("Send size of data: "+str(self.__ioData.SizeOfDataList()))
            
            command = self.__connClient.recv(1).decode("utf8")
            if DEBUG:
                print("IsChanged command : " + command)

            if command == comProtcol.ok.value:
                if DEBUG:
                    print("Start send data")

                for data in self.__ioData.GetData():
                    self.__connClient.send( struct.pack(">10s?", data[0].encode("utf8"), data[2]) )
                self.__changed = False

                if DEBUG:
                    print("End send Data")
            elif command == comProtcol.fail.value:
                return

        else:
            if DEBUG:
                print("Nothing changed")
            self.__connClient.send(comProtcol.end.value.encode("utf8"))


    def ChangeState(self):
        if DEBUG:
            print("Function ChangeState")

        self.__connClient.send( comProtcol.ok.value.encode("utf8") )
        name, state = struct.unpack(">10s?", self.__connClient.recv(SIZEOFDATA))

        if DEBUG:
            print(str(name) + " : " + str(state))

        self.__ioData.ChangeIO( str(name, "utf8").split('\x00')[0], state )
        self.__changed = True


    def run(self):
        alive = True
        while alive: #stop by timeout is missing
            try:
                command = self.__connClient.recv(1).decode("utf8")
                if DEBUG:
                    print("clientHandler command : " + str(command))
            except:
                print("Error : " + str(sys.exc_info()))
                break

            if command == comProtcol.isChanged.value:
                self.IsChanged()
            elif command == comProtcol.changeState.value:
                self.ChangeState()
            elif command == comProtcol.closeCon.value:
                alive = False
                print("Close connection")
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
        Server.ioStream.CreateIO( "MotorLinks", 1)
        Server.ioStream.CreateIO( "MotorRechts", 1)

        Server.ioStream.ChangeIO("Licht1", True)

    else:
        print("Live mode")
        Server.ioStream.CreateIO( "LED1", 4)

    Server.Main()
    input("End")