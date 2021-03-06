CREATE OR REPLACE TRIGGER BOARD_TRI
AFTER INSERT ON BOARD
FOR EACH ROW
BEGIN	
    INSERT INTO BOARDPOINT
    VALUES(:NEW.BCODE,0,0,0,0,0,0,0,0);
END; 
/

CREATE OR REPLACE TRIGGER COMMENT_TRI
AFTER INSERT ON COMMENTS
FOR EACH ROW
BEGIN	
    INSERT INTO COMMENTSPOINT
    VALUES(:NEW.CCODE,0,0,0,0,0);
END; 
/

CREATE OR REPLACE TRIGGER BMEDAL_TRI
AFTER UPDATE ON BOARDPOINT
FOR EACH ROW
BEGIN	    
    IF(:NEW.MEDAL!=:OLD.MEDAL)
    THEN 
        UPDATE MEMBER
        SET MEDAL=MEDAL+1
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER CMEDAL_TRI
AFTER UPDATE ON COMMENTSPOINT
FOR EACH ROW
BEGIN	    
    IF(:NEW.MEDAL!=:OLD.MEDAL)
    THEN 
        UPDATE MEMBER
        SET MEDAL=MEDAL+1
        WHERE ID=(SELECT WRITERID FROM COMMENTS WHERE CCODE=:NEW.CCODE);
    END IF;
END; 
/
--게시글 신고 트리거
CREATE OR REPLACE TRIGGER BREPORT_TRI
AFTER INSERT ON REPORTLIST
FOR EACH ROW
BEGIN	    
    UPDATE MEMBER
    SET REPORT=REPORT+1
    WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    
    UPDATE BOARDPOINT
    SET REPORT=REPORT+1
    WHERE BCODE=:NEW.BCODE;
END; 
/

--댓글 신고 트리거
CREATE OR REPLACE TRIGGER CREPORT_TRI
AFTER INSERT ON CREPORTLIST
FOR EACH ROW
BEGIN	    
    UPDATE MEMBER
    SET REPORT=REPORT+1
    WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=(SELECT BCODE FROM COMMENTS WHERE CCODE=:NEW.CCODE));
    
    UPDATE COMMENTSPOINT
    SET REPORT=REPORT+1
    WHERE CCODE=:NEW.CCODE;
END; 
/
--게시글 공감 트리거
CREATE OR REPLACE TRIGGER BRECOM_TRI
AFTER UPDATE ON BOARDPOINT
FOR EACH ROW
BEGIN	  
    IF(:NEW.BEST!=:OLD.BEST)
    THEN 
        UPDATE MEMBER
        SET EXP=EXP+5
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    END IF;
    
    IF(:NEW.GOOD!=:OLD.GOOD)
    THEN 
        UPDATE MEMBER
        SET EXP=EXP+3
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    END IF;      
END; 
/

--댓글 공감 트리거
CREATE OR REPLACE TRIGGER CRECOM_TRI
AFTER UPDATE ON COMMENTSPOINT
FOR EACH ROW
BEGIN	  
    IF(:NEW.GOOD!=:OLD.GOOD)
    THEN 
        UPDATE MEMBER
        SET EXP=EXP+3
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=(SELECT BCODE FROM COMMENTS WHERE CCODE=:NEW.CCODE));
    END IF;  
END; 
/