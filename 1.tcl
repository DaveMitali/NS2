#creates a simulator object
set ns [new Simulator]    

#opens file out.nam for writing and gives it to file handle 'nf'
#tells the simulation object that we created the above file to write all simulation data
set nf [open out.nam w] 
$ns namtrace-all $nf

#finish procedure that closes the trace file and starts nam    
proc finish {} {    
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
}

#$ns node creates a new node object
#2 nodes are created and assigned to handles n0 and n1
set n0 [$ns node]    
set n1 [$ns node]    

#creates a duplex-link between n0 and n1 with bandwidth 1Mb, delay of 10ms and DropTail queue
$ns duplex-link $n0 $n1 1Mb 10ms DropTail    

#data is sent from one agent to another 
#creates data object to send data from n0 to n1
#creates UDP agent and attach it to n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

#attach a constant bit rate traffic generator to the UDP agent
#packet size is 500 bytes and a packet is sent every 0.005 seconds (200 packets per second)
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

#creates a null agent which is the traffic sink and attach it to node n1
set null1 [new Agent/Null]
$ns attach-agent $n1 $null1

#connect the 2 agents to each other
$ns connect $udp0 $null1

#tell the cbr agent when to send the data and when to stop sending
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

#tells the simulator object to execute the finish procedure after 5.0 seconds of simulation time
$ns at 5.0 "finish"    

#starts simulation
$ns run            
