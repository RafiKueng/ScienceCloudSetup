import unittest
import requests as rq

url = "http://130.60.24.163/_webserver_test.tmp"

class WebServerTest(unittest.TestCase):

    def setUp(self):
        self.r = rq.get(url)

    def tearDown(self):
        pass

    
    def test_if_200(self):
        self.assertEqual(self.r.status_code, 200,
                         "statuscode is not 200")

    def test_if_responding(self):
        self.assertEqual(self.r.text, "webserver running",
                         'no answer from %s'%url)

