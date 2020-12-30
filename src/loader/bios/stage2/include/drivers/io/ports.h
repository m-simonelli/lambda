/*
 *  ports.c
 *  Copyright Marco Simonelli 2020
 *  You are free to redistribute/modify this code under the
 *  terms of the GPL version 3 (see the file LICENSE)
 */

#ifndef _drivers_io_ports_h
#define _drivers_io_ports_h

typedef unsigned char port_byte_t;
typedef unsigned short port_word_t;
typedef unsigned short port_t;

/*!
    @function port_byte_in
    Given a port, return a byte read from that port

    @param port
    The port to be read from

    @return
    One byte read from port `port`
!*/
port_byte_t port_byte_in(port_t port);

/*!
    @function port_byte_out
    Given a port, write a byte to that port

    @param port
    The port to write to

    @param data
    One byte to be written to port `port`
!*/
void port_byte_out(port_t port, port_byte_t data);

/*!
    @function port_word_in
    Given a port, return a word read from that port

    @param port
    The port to be read from

    @return
    One word read from port `port`
!*/
port_word_t port_word_in(port_t port);

/*!
    @function port_word_out
    Given a port, write a word to that port

    @param port
    The port to write to

    @param data
    One word to be written to port `port`
!*/
void port_word_out(port_t port, port_word_t data);

/*!
    @function io_wait
    Make the CPU wait a few milliseconds so that a mem op can be completed
!*/
void io_wait();

#endif