def get_command_line_argument  
    # ARGV is an array that Ruby defines for us,  
    # which contains all the arguments we passed to it  
    # when invoking the script from the command line.  
    # https://docs.ruby-lang.org/en/2.4.0/ARGF.html  
    if ARGV.empty?    
        puts "Usage: ruby lookup.rb <domain>"    
        exit
    end  
    ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument
# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")[1..]  #excluding the 1st line with the titles

def parse_dns(dns_raw)
    dns_raw = dns_raw.map{ |d| d.split(",") }        #splitting the raw data.
    dns_raw.each do |dns|                            #stripping each word of its-
        dns.each { |word| word.strip! }              #spaces and escape sequences.
    end                                              

    dns_records = {}
    dns_records["A"] = {}                          #creating nested hash for record type 'A'.
    dns_records["CNAME"] = {}                      #creating nested hash for record type 'CNAME'.
                        
    dns_raw.each do |dns|               
        if dns[0]=="A"                             #when record type is 'A',
            dns_records["A"][dns[1]] = dns.last    #storing values for the corresponding key inside nested hash.
        elsif dns[0]=="CNAME"                      #repeating the same for record type 'CNAME'.
            dns_records["CNAME"][dns[1]] = dns.last
        end
    end
    dns_records
end


def resolve(dns_records, lookup_chain, domain)
    if dns_records["A"][domain]!=nil                                    #base condition
        return lookup_chain << dns_records["A"][domain]  
                       
    elsif dns_records["CNAME"][domain]!=nil
        lookup_chain << dns_records["CNAME"][domain]
        resolve(dns_records,lookup_chain,dns_records["CNAME"][domain])  #recursive call
    else
        puts "Error: record not found for #{domain}"                    #error condition
        exit
    end
end

 
# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)

lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
