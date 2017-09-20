#creates a simulator object
set ns [new Simulator]    

#set color to ftp flow
#written after creation of simulator object
$ns color 1 Blue
$ns color 2 Red

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
#4 nodes are created and assigned to handles n0, n1, n2 and n3
set n0 [$ns node]    
set n1 [$ns node]    
set n2 [$ns node]
set n3 [$ns node]

#for star topology of 4 nodes we need 3 duplex links
#creates a duplex-link between n0-n2,n1-n2,n3-n2 with bandwidth 1Mb, delay of 10ms and DropTail queue
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms DropTail

#since topology is of awkward orientation till here we re-orient it
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n3 $n2 orient left

#create 2 TCP agents at n0 and n1 (sources) 
#create a sink agent at n3 (TCP sink)
set tcp0 [new Agent/TCP]
set tcp1 [new Agent/TCP]
set sink3 [new Agent/TCPSink]

#assign color to FTP agents
$tcp0 set fid_ 1
$tcp1 set fid_ 2
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $tcp1
$ns attach-agent $n3 $sink3

#create ftp source at n0 and n1 and attach to agents
set ftp0 [new Application/FTP]
$ftp0 set packetSize_ 500
$ftp0 set interval_ 0.005
$ftp0 attach-agent $tcp0
set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 500
$ftp1 set interval_ 0.005
$ftp1 attach-agent $tcp1

#connect 2 ftp agents to sink agent
$ns connect $tcp0 $sink3
$ns connect $tcp1 $sink3

#first ftp agent starts sending at 0.5 seconds and stops sending at 4.5 seconds
#second ftp agent starts sending at 1 seconds and stops sending at 4 seconds
$ns at 0.5 "$ftp0 start"
$ns at 4.5 "$ftp0 stop"
$ns at 1 "$ftp1 start"
$ns at 4 "$ftp1 stop"

#tells the simulator object to execute the finish procedure after 5.0 seconds of simulation time
$ns at 5.0 "finish"    

#starts simulation
$ns run   